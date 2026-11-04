import Foundation

// Replaces only Apple's path source in the standalone runners. The production
// monitor, its real timer, and main-queue dispatch run unchanged.
final class NWPath {
    enum Status { case satisfied, unsatisfied, requiresConnection }
    let status: Status
    init(_ status: Status) { self.status = status }
}

final class NWPathMonitor {
    static var instances: [NWPathMonitor] = []
    var pathUpdateHandler: ((NWPath) -> Void)?
    private(set) var isCancelled = false
    private(set) var queue: DispatchQueue?

    init() { Self.instances.append(self) }
    func start(queue: DispatchQueue) { self.queue = queue }
    func cancel() { isCancelled = true }

    func send(_ status: NWPath.Status) {
        precondition(Thread.isMainThread)
        precondition(queue === DispatchQueue.main, "Production path callbacks must use the main queue")
        pathUpdateHandler?(NWPath(status))
    }
}
