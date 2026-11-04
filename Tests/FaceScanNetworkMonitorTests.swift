import Foundation

private final class WeakMonitorReference {
    weak var value: FaceScanNetworkMonitor?
    init(_ value: FaceScanNetworkMonitor?) { self.value = value }
}

@main
struct FaceScanNetworkMonitorTests {
    @MainActor static var passed = 0

    @MainActor static func test(_ name: String, _ body: () -> Void) {
        body()
        passed += 1
        print("PASS \(passed): \(name)")
    }

    @MainActor static func main() async {
        test("Idle preview never reports slowness") {
            var state = FaceScanNetworkState()
            precondition(state.nextEvent(at: 10_000) == nil)
        }
        test("Requests completing before five seconds stay silent") {
            var state = FaceScanNetworkState()
            let id = UUID()
            state.pendingRequests[id] = 100
            precondition(state.nextEvent(at: 104.999) == nil)
            state.pendingRequests.removeValue(forKey: id)
            precondition(state.nextEvent(at: 105) == nil)
        }
        test("Slow warning starts at the five-second boundary") {
            var state = FaceScanNetworkState()
            state.pendingRequests[UUID()] = 100
            precondition(state.nextEvent(at: 104.999) == nil)
            precondition(state.nextEvent(at: 105) == .show(.slow))
        }
        test("Unchanged slow warning repeats only after fifteen seconds") {
            var state = FaceScanNetworkState()
            state.pendingRequests[UUID()] = 100
            precondition(state.nextEvent(at: 105) == .show(.slow))
            for time in stride(from: 105.1, through: 119.9, by: 0.1) {
                precondition(state.nextEvent(at: time) == nil)
            }
            precondition(state.nextEvent(at: 120) == .show(.slow))
        }
        test("Offline warning is immediate and overrides a slow warning") {
            var state = FaceScanNetworkState()
            state.pendingRequests[UUID()] = 0
            precondition(state.nextEvent(at: 5) == .show(.slow))
            state.isOffline = true
            precondition(state.nextEvent(at: 5.1) == .show(.offline))
        }
        test("Offline repeats are throttled, including request completions") {
            var state = FaceScanNetworkState()
            state.isOffline = true
            precondition(state.nextEvent(at: 0) == .show(.offline))
            state.pendingRequests.removeAll()
            precondition(state.nextEvent(at: 14.999) == nil)
            precondition(state.nextEvent(at: 15) == .show(.offline))
        }
        test("Restored connection clears the warning once") {
            var state = FaceScanNetworkState()
            state.isOffline = true
            precondition(state.nextEvent(at: 0) == .show(.offline))
            state.isOffline = false
            precondition(state.nextEvent(at: 1) == .clear)
            precondition(state.nextEvent(at: 2) == nil)
        }
        test("Restored path still warns if a request remains stalled") {
            var state = FaceScanNetworkState()
            state.pendingRequests[UUID()] = 0
            state.isOffline = true
            precondition(state.nextEvent(at: 5) == .show(.offline))
            state.isOffline = false
            precondition(state.nextEvent(at: 6) == .show(.slow))
        }
        test("A fast concurrent request does not hide a stalled request") {
            var state = FaceScanNetworkState()
            let fast = UUID()
            state.pendingRequests[UUID()] = 0
            state.pendingRequests[fast] = 4
            state.pendingRequests.removeValue(forKey: fast)
            precondition(state.nextEvent(at: 5) == .show(.slow))
            state.pendingRequests.removeAll()
            precondition(state.nextEvent(at: 6) == .clear)
        }
        for code: URLError.Code in [.notConnectedToInternet, .networkConnectionLost, .dataNotAllowed] {
            test("Transport error \(code.rawValue) reports offline even with an available path") {
                var state = FaceScanNetworkState()
                state.recordFailure(URLError(code), at: 100)
                precondition(state.nextEvent(at: 100) == .show(.offline))
                precondition(state.nextEvent(at: 104.999) == nil)
                precondition(state.nextEvent(at: 105) == .clear)
            }
        }
        test("URL timeout reports slow immediately") {
            var state = FaceScanNetworkState()
            state.recordFailure(URLError(.timedOut), at: 100)
            precondition(state.nextEvent(at: 100) == .show(.slow))
            precondition(state.nextEvent(at: 105) == .clear)
        }
        test("A timeout cannot override a known offline path") {
            var state = FaceScanNetworkState()
            state.isOffline = true
            state.recordFailure(URLError(.timedOut), at: 100)
            precondition(state.nextEvent(at: 100) == .show(.offline))
        }
        test("HTTP/server errors with matching numeric codes are ignored") {
            var state = FaceScanNetworkState()
            state.recordFailure(NSError(domain: "HTTP", code: NSURLErrorNotConnectedToInternet), at: 0)
            precondition(state.nextEvent(at: 0) == nil)
        }
        for code: URLError.Code in [.cancelled, .badURL, .userAuthenticationRequired] {
            test("Non-connectivity error \(code.rawValue) does not report weak internet") {
                var state = FaceScanNetworkState()
                state.recordFailure(URLError(code), at: 0)
                precondition(state.nextEvent(at: 0) == nil)
            }
        }
        test("A new scan has no inherited requests, errors, or cooldown") {
            var state = FaceScanNetworkState()
            precondition(state.nextEvent(at: 100) == nil)
            state.isOffline = true
            precondition(state.nextEvent(at: 100) == .show(.offline))
        }

        var events: [FaceScanNetworkState.Event] = []
        let monitor = FaceScanNetworkMonitor()
        monitor.start { event in
            precondition(Thread.isMainThread, "UI callback must always run on the main thread")
            events.append(event)
        }
        let firstPath = NWPathMonitor.instances.last!
        test("Path adapter delivers offline and recovery to the production monitor") {
            firstPath.send(.satisfied)
            precondition(events.isEmpty)
            firstPath.send(.unsatisfied)
            precondition(events == [.show(.offline)])
            firstPath.send(.unsatisfied)
            precondition(events.count == 1)
            firstPath.send(.satisfied)
            precondition(events == [.show(.offline), .clear])
        }
        test("A path requiring a connection reports unavailable connectivity") {
            events.removeAll()
            firstPath.send(.requiresConnection)
            precondition(events == [.show(.offline)])
            firstPath.send(.satisfied)
        }
        let oldRequest = monitor.beginRequest()
        let latePathCallback = firstPath.pathUpdateHandler!
        test("Restart cancels the old path and ignores its delayed callbacks") {
            monitor.start { events.append($0) }
            events.removeAll()
            precondition(firstPath.isCancelled)
            latePathCallback(NWPath(.unsatisfied))
            monitor.endRequest(oldRequest, error: URLError(.timedOut))
            precondition(events.isEmpty)
        }
        test("Unknown and cancelled requests cannot show a late warning") {
            monitor.endRequest(UUID(), error: URLError(.timedOut))
            let cancelled = monitor.beginRequest()
            monitor.cancelPendingRequests()
            monitor.endRequest(cancelled, error: URLError(.notConnectedToInternet))
            precondition(events.isEmpty)
        }
        test("Stopping monitoring ignores subsequent request completions") {
            let id = monitor.beginRequest()
            monitor.stop()
            monitor.endRequest(id, error: URLError(.timedOut))
            let offscreenID = monitor.beginRequest()
            monitor.start { events.append($0) }
            monitor.endRequest(offscreenID, error: URLError(.timedOut))
            precondition(events.isEmpty)
        }
        monitor.stop()
        monitor.start { event in
            precondition(Thread.isMainThread)
            events.append(event)
        }
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let work = DispatchWorkItem {
                let id = monitor.beginRequest()
                monitor.endRequest(id, error: URLError(.timedOut))
                DispatchQueue.main.async { continuation.resume() }
            }
            DispatchQueue.global().async(execute: work)
        }
        test("Background upload completion reaches the UI on the main thread") {
            precondition(events == [.show(.slow)])
        }
        monitor.stop()
        events.removeAll()
        monitor.start { events.append($0) }
        let stalled = monitor.beginRequest()
        try? await Task.sleep(for: .milliseconds(4200))
        test("Real watchdog timer stays silent before five seconds") {
            precondition(events.isEmpty)
        }
        try? await Task.sleep(for: .milliseconds(2000))
        test("Real watchdog timer warns for an unfinished request") {
            precondition(events == [.show(.slow)])
        }
        test("Completing the timed request clears the visible warning") {
            monitor.endRequest(stalled)
            precondition(events == [.show(.slow), .clear])
        }
        monitor.stop()
        test("Releasing a monitor cancels its underlying path source") {
            var disposable: FaceScanNetworkMonitor? = FaceScanNetworkMonitor()
            let reference = WeakMonitorReference(disposable)
            disposable?.start { _ in }
            let path = NWPathMonitor.instances.last!
            disposable = nil
            precondition(reference.value == nil && path.isCancelled)
        }
        print("RESULT: \(passed) monitor/state test cases passed")
    }
}
