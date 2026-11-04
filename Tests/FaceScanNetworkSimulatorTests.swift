import UIKit

@main final class FaceScanNetworkSimulatorTests: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let presenter = UIViewController()
    private var passed: [String] = []
    private let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        try? FileManager.default.removeItem(at: documents.appendingPathComponent("result.txt"))
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = presenter
        presenter.view.backgroundColor = UIColor(white: 0.94, alpha: 1)
        window.makeKeyAndVisible()
        self.window = window
        Task { @MainActor in await runTests() }
        return true
    }

    private func runTests() async {
        window!.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        await pause(600)
        let api = TestScanAPI()
        let delegate = MeasurementDelegate(api: api)
        let scan = await presentScan(delegate: delegate)
        let path = NWPathMonitor.instances.last!
        path.send(.satisfied)
        check("Healthy preview has no connection toast", toast(in: scan) == nil)
        path.send(.unsatisfied)
        check("Going offline shows the correct toast immediately", message(in: scan) == FaceScanNetworkWarning.offline.message)
        verifyLayout(in: scan)
        snapshot("network-toast-portrait.png")
        path.send(.unsatisfied)
        check("Repeated path updates do not stack toasts", toasts(in: scan).count == 1)
        path.send(.satisfied)
        check("Connection recovery removes the toast", toast(in: scan) == nil)

        delegate.anuraMeasurementControllerDidStartMeasuring(scan)
        await pause(4200)
        check("Creating measurement stays silent before five seconds", toast(in: scan) == nil)
        await pause(2000)
        check("Delayed measurement creation shows slow internet", message(in: scan) == FaceScanNetworkWarning.slow.message)
        api.creation?(.success(ID(id: "test-measurement")))
        check("Successful creation clears its delay warning", toast(in: scan) == nil)

        delegate.anuraMeasurementControllerDidGetPayload(scan, MeasurementPayload(chunkOrder: 0, numberOfChunks: 6, payload: Data()))
        await pause(200)
        precondition(api.upload != nil, "Upload must actually reach the fake API")
        await pause(6000)
        check("Delayed chunk upload shows slow internet", message(in: scan) == FaceScanNetworkWarning.slow.message)
        api.upload?(.success(ID(id: "test-chunk")))
        check("Upload success clears the warning", toast(in: scan) == nil)

        let subscriber = delegate.measurementResultsSubscriber!
        delegate.didDisconnect(subscriber)
        await pause(6200)
        check("Delayed results reconnection shows slow internet", message(in: scan) == FaceScanNetworkWarning.slow.message)
        delegate.didConnect(subscriber)
        check("Results reconnection clears its warning", toast(in: scan) == nil)
        let oldSubscriber = MeasurementResultsSubscriber(token: "old-scan")
        delegate.didGetError(oldSubscriber, error: URLError(.notConnectedToInternet))
        check("Events from an old results subscriber are ignored", toast(in: scan) == nil)

        delegate.didGetError(subscriber, error: URLError(.timedOut))
        check("Socket timeout shows the slow warning immediately", message(in: scan) == FaceScanNetworkWarning.slow.message)
        await pause(1200)
        path.send(.unsatisfied)
        check("Offline replaces slow with one toast", message(in: scan) == FaceScanNetworkWarning.offline.message && toasts(in: scan).count == 1)
        await pause(4100)
        check("The old toast timer does not dismiss its replacement", message(in: scan) == FaceScanNetworkWarning.offline.message)
        await pause(1200)
        check("Toast auto-dismisses after five seconds", toast(in: scan) == nil)
        path.send(.satisfied)
        delegate.resetMeasurementID()
        check("Cancelling measurement clears pending slow warnings", toast(in: scan) == nil)

        // Reuse the same delegate across the scan replacement used for rotation.
        presenter.dismiss(animated: false)
        await pause(250)
        check("Closing scan cancels its path monitor and removes its toast", path.isCancelled && toast(in: scan) == nil)
        window!.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
        await pause(700)
        check("Simulator reached landscape", window!.bounds.width > window!.bounds.height)
        let landscapeScan = await presentScan(delegate: delegate)
        let landscapePath = NWPathMonitor.instances.last!
        path.send(.unsatisfied)
        check("Delayed path event from the old scan cannot warn in the new scan", toast(in: landscapeScan) == nil)
        landscapePath.send(.unsatisfied)
        check("A new scan starting offline still warns", message(in: landscapeScan) == FaceScanNetworkWarning.offline.message)
        verifyLayout(in: landscapeScan)
        snapshot("network-toast-landscape.png")

        landscapePath.send(.satisfied)
        delegate.createNewMeasurement()
        api.creation?(.failure(URLError(.timedOut)))
        check("Measurement creation timeout shows a slow warning", message(in: landscapeScan) == FaceScanNetworkWarning.slow.message)
        delegate.createNewMeasurement()
        api.creation?(.success(ID(id: "retry-measurement")))
        api.upload = nil
        delegate.anuraMeasurementControllerDidGetPayload(landscapeScan, MeasurementPayload(chunkOrder: 0, numberOfChunks: 6, payload: Data()))
        await pause(200)
        precondition(api.upload != nil)
        api.upload?(.failure(URLError(.networkConnectionLost)))
        check("Upload connection-loss error shows an offline warning", message(in: landscapeScan) == FaceScanNetworkWarning.offline.message)

        // SDK layout updates can add views; the toast must remain visible.
        let sdkOverlay = UIView(frame: landscapeScan.view.bounds)
        landscapeScan.view.addSubview(sdkOverlay)
        delegate.anuraMeasurementControllerDidUpdate(landscapeScan, info: MeasurementPipelineInfo(state: .measuring))
        check("Pipeline updates keep the toast above SDK views", landscapeScan.view.subviews.last === toast(in: landscapeScan))
        sdkOverlay.removeFromSuperview()
        delegate.anuraMeasurementControllerDidFinishMeasuring(landscapeScan)
        check("Finishing scan immediately removes the toast and stops monitoring", toast(in: landscapeScan) == nil && landscapePath.isCancelled)
        // Allow the full-screen results presentation to finish before cleanup.
        await pause(1200)
        delegate.resetMeasurementID()
        // The test app exits below. Avoid collapsing both custom/full-screen
        // presentations at once merely to tear down this fixture.

        let hiddenController = UIViewController()
        let standaloneToast = FaceScanNetworkToast()
        standaloneToast.show(.offline, in: hiddenController)
        check("Offscreen controller cannot display a toast", hiddenController.viewIfLoaded == nil)

        let report = passed.map { "PASS: \($0)" }.joined(separator: "\n")
            + "\nRESULT: \(passed.count) simulator integration/UI test cases passed\n"
        try! report.write(to: documents.appendingPathComponent("result.txt"), atomically: true, encoding: .utf8)
        print(report)
        fflush(stdout)
        exit(0)
    }

    private func presentScan(delegate: MeasurementDelegate) async -> AnuraMeasurementViewController {
        let scan = AnuraMeasurementViewController()
        scan.delegate = delegate
        let bounds = window!.bounds
        let landscape = bounds.width > bounds.height
        scan.preferredContentSize = CGSize(width: min(bounds.width, bounds.height) * (landscape ? 0.9 : 0.8), height: max(bounds.width, bounds.height) * 0.7)
        scan.modalPresentationStyle = landscape ? .custom : .formSheet
        if landscape { scan.transitioningDelegate = scan }
        presenter.present(scan, animated: false)
        await pause(350)
        return scan
    }

    private func verifyLayout(in scan: AnuraMeasurementViewController) {
        scan.view.layoutIfNeeded()
        let toast = toast(in: scan)!
        let label = toast.subviews.compactMap { $0 as? UILabel }.first!
        check("Toast fits popup \(Int(scan.view.bounds.width))x\(Int(scan.view.bounds.height))", scan.view.bounds.contains(toast.frame) && !toast.hasAmbiguousLayout)
        let required = label.sizeThatFits(CGSize(width: label.bounds.width, height: .greatestFiniteMagnitude))
        check("Warning text is fully visible and does not intercept touches", label.bounds.height >= required.height - 1 && !toast.isUserInteractionEnabled)
        check("Close button remains unobstructed", !toast.frame.intersects(scan.closeButton.frame))
    }
    private func check(_ name: String, _ condition: @autoclosure () -> Bool) {
        precondition(condition(), name)
        passed.append(name)
        print("PASS \(passed.count): \(name)")
        fflush(stdout)
    }
    private func toasts(in controller: UIViewController) -> [UIView] {
        controller.view.subviews.filter { $0.accessibilityIdentifier == "faceScan.networkToast" }
    }
    private func toast(in controller: UIViewController) -> UIView? { toasts(in: controller).first }
    private func message(in controller: UIViewController) -> String? {
        toast(in: controller)?.subviews.compactMap { $0 as? UILabel }.first?.text
    }
    private func pause(_ milliseconds: Int) async { try? await Task.sleep(for: .milliseconds(milliseconds)) }
    private func snapshot(_ name: String) {
        let renderer = UIGraphicsImageRenderer(bounds: window!.bounds)
        let image = renderer.image { _ in window!.drawHierarchy(in: window!.bounds, afterScreenUpdates: true) }
        try! image.pngData()!.write(to: documents.appendingPathComponent(name))
    }
}
