import Foundation
import Network

enum FaceScanNetworkWarning: Equatable {
    case offline
    case slow

    var message: String {
        switch self {
        case .offline:
            return "No internet connection. Please check your connection."
        case .slow:
            return "Slow internet connection. Your face scan may take longer."
        }
    }
}

/// Uses elapsed scan requests, not Wi-Fi type or Low Data Mode, to detect delays.
struct FaceScanNetworkState {
    static let slowRequestInterval: TimeInterval = 5
    static let reminderInterval: TimeInterval = 15

    var isOffline = false
    var pendingRequests: [UUID: TimeInterval] = [:]
    private var failure: (warning: FaceScanNetworkWarning, time: TimeInterval)?
    private var lastWarning: FaceScanNetworkWarning?
    private var lastWarningTime: TimeInterval = -.infinity

    enum Event: Equatable {
        case show(FaceScanNetworkWarning)
        case clear
    }

    mutating func recordFailure(_ error: Error, at time: TimeInterval) {
        let error = error as NSError
        guard error.domain == NSURLErrorDomain else { return }
        switch error.code {
        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost, NSURLErrorDataNotAllowed:
            failure = (.offline, time)
        case NSURLErrorTimedOut:
            failure = (.slow, time)
        default:
            break
        }
    }

    mutating func nextEvent(at time: TimeInterval) -> Event? {
        let warning: FaceScanNetworkWarning?
        if isOffline {
            warning = .offline
        } else if let failure, time - failure.time < Self.slowRequestInterval {
            warning = failure.warning
        } else if pendingRequests.values.contains(where: { time - $0 >= Self.slowRequestInterval }) {
            warning = .slow
        } else {
            warning = nil
        }

        guard let warning else {
            guard lastWarning != nil else { return nil }
            lastWarning = nil
            return .clear
        }
        guard warning != lastWarning || time - lastWarningTime >= Self.reminderInterval else { return nil }
        lastWarning = warning
        lastWarningTime = time
        return .show(warning)
    }
}

/// All state is serialized on the main queue, including upload callbacks.
final class FaceScanNetworkMonitor {
    private var pathMonitor: NWPathMonitor?
    private var timer: Timer?
    private var state = FaceScanNetworkState()
    private var onEvent: ((FaceScanNetworkState.Event) -> Void)?

    func start(onEvent: @escaping (FaceScanNetworkState.Event) -> Void) {
        onMain { [self] in
            stop()
            self.onEvent = onEvent
            let monitor = NWPathMonitor()
            pathMonitor = monitor
            monitor.pathUpdateHandler = { [weak self, weak monitor] path in
                guard let self, let monitor, self.pathMonitor === monitor else { return }
                self.state.isOffline = path.status != .satisfied
                self.evaluate()
            }
            monitor.start(queue: .main)
            let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
                self?.evaluate()
            }
            self.timer = timer
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func stop() {
        onMain { [self] in
            pathMonitor?.cancel()
            pathMonitor = nil
            timer?.invalidate()
            timer = nil
            onEvent = nil
            state = FaceScanNetworkState()
        }
    }

    @discardableResult
    func beginRequest() -> UUID {
        let id = UUID()
        onMain { [self] in
            guard onEvent != nil else { return }
            state.pendingRequests[id] = ProcessInfo.processInfo.systemUptime
        }
        return id
    }

    func endRequest(_ id: UUID, error: Error? = nil) {
        onMain { [self] in
            // Completions from a closed, cancelled, or rotated scan are ignored.
            guard state.pendingRequests.removeValue(forKey: id) != nil else { return }
            if let error {
                state.recordFailure(error, at: ProcessInfo.processInfo.systemUptime)
            }
            evaluate()
        }
    }

    func cancelPendingRequests() {
        onMain { [self] in
            state.pendingRequests.removeAll()
            evaluate()
        }
    }

    private func evaluate() {
        guard let event = state.nextEvent(at: ProcessInfo.processInfo.systemUptime) else { return }
        onEvent?(event)
    }

    private func onMain(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }

    deinit {
        pathMonitor?.cancel()
        timer?.invalidate()
    }
}
