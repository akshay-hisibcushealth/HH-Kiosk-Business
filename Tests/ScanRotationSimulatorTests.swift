import UIKit

// A no-camera Anura substitute. The runner compiles the production scan
// controller and presentation controller; only SDK capture is replaced.
final class TestMeasurementConfiguration {
    var isUseExternalCameraOnly = false
}

class AnuraMeasurementViewController: UIViewController {
    let measurementConfiguration = TestMeasurementConfiguration()
    private(set) var stopCount = 0
    func stopExtracting() {}
    func stop() { stopCount += 1 }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let preview = UIView()
        preview.backgroundColor = .darkGray
        preview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(preview)
        NSLayoutConstraint.activate([
            preview.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            preview.heightAnchor.constraint(equalTo: preview.widthAnchor),
            preview.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            preview.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
        ])
    }
}

@main final class ScanRotationTests: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let presenter = UIViewController()
    private var scanner: OrientationAwareAnuraMeasurementViewController?
    private var restartCount = 0
    private var outsideDismissals = 0
    private var portraitSize = CGSize.zero
    private let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        try? FileManager.default.removeItem(at: documents.appendingPathComponent("result.txt"))
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = presenter
        presenter.view.backgroundColor = .systemBlue
        window.makeKeyAndVisible()
        self.window = window
        Task { @MainActor in
            window.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            await pause(900)

            presentScanner()
            await pause(700)
            portraitSize = scanner!.view.bounds.size
            precondition(portraitSize.height < window.bounds.height * 0.85)
            presenter.dismiss(animated: false)
            await pause(200)

            // Reproduce a popup prepared for landscape while the interface has
            // already returned to portrait before its presentation finishes.
            presentScanner(forcedLandscape: true)
            await pause(1200)
            verifySettledPopup(landscape: false)
            precondition(restartCount == 1, "A stale presentation must restart exactly once")
            print("PASS: stale landscape presentation corrected on appearance")
            fflush(stdout)

            for cycle in 0..<8 {
                for mask: UIInterfaceOrientationMask in [.landscapeLeft, .portrait, .landscapeRight, .portrait] {
                    requestOrientation(mask)
                    await pause(cycle.isMultiple(of: 2) ? 150 : 330)
                }
                let finalMask: UIInterfaceOrientationMask = cycle.isMultiple(of: 2) ? .landscapeRight : .portrait
                // UIKit can reject requests during modal transitions. Allow
                // those to settle, then verify an actual rotation in each direction.
                await pause(800)
                requestOrientation(finalMask)
                await pause(1500)
                verifySettledPopup(landscape: finalMask != .portrait)
                print("PASS: rapid rotation cycle \(cycle + 1), restarts=\(restartCount)")
                fflush(stdout)
            }

            // Orientation changes must not dismiss a result screen on top of
            // the scanner, or reopen a popup after the user dismisses it.
            let results = UIViewController()
            results.modalPresentationStyle = .fullScreen
            scanner!.present(results, animated: false)
            await pause(300)
            let beforeResults = restartCount
            window.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeLeft))
            await pause(900)
            precondition(restartCount == beforeResults && scanner?.presentedViewController === results)
            results.dismiss(animated: false)
            await pause(1200)
            verifySettledPopup(landscape: true)
            scanner!.perform(NSSelectorFromString("dismissFromOutsideTap"))
            await pause(600)
            let afterDismissal = restartCount
            window.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            await pause(900)
            precondition(outsideDismissals == 1 && presenter.presentedViewController == nil)
            precondition(restartCount == afterDismissal, "Dismissed scan must not reopen")
            try! "PASS: stale presentation, rapid interface rotations, portrait/landscape sizing, results and outside dismissal.\n".write(
                to: documents.appendingPathComponent("result.txt"), atomically: true, encoding: .utf8
            )
            exit(0)
        }
        return true
    }

    private func presentScanner(forcedLandscape: Bool? = nil) {
        let landscape = forcedLandscape ?? (window!.bounds.width > window!.bounds.height)
        let controller = OrientationAwareAnuraMeasurementViewController()
        controller.startedInLandscape = landscape
        let shortSide = min(window!.bounds.width, window!.bounds.height)
        let longSide = max(window!.bounds.width, window!.bounds.height)
        controller.requiredContentSize = CGSize(width: shortSide * (landscape ? 0.9 : 0.8), height: longSide * 0.7)
        controller.preferredContentSize = controller.requiredContentSize!
        controller.modalPresentationStyle = landscape ? .custom : .formSheet
        if landscape { controller.transitioningDelegate = controller }
        controller.restartAfterOrientationChange = { [weak self, weak controller] in
            guard let self else { return }
            precondition(controller?.stopCount == 1, "Stop camera capture before replacing the popup")
            restartCount += 1
            presentScanner()
        }
        controller.onOutsideDismissal = { [weak self] in self?.outsideDismissals += 1 }
        scanner = controller
        presenter.present(controller, animated: true)
    }

    private func verifySettledPopup(landscape: Bool) {
        let window = window!
        guard let scanner, presenter.presentedViewController === scanner else {
            preconditionFailure("Scan popup was lost during rotation")
        }
        saveScreenshot(name: landscape ? "landscape" : "portrait")
        precondition((window.bounds.width > window.bounds.height) == landscape,
                     "Interface rotation did not settle: \(window.bounds), requested landscape=\(landscape)")
        precondition(scanner.startedInLandscape == landscape, "Stale scan layout survived rotation")
        precondition(scanner.modalPresentationStyle == (landscape ? .custom : .formSheet))
        let frame = scanner.view.convert(scanner.view.bounds, to: window)
        precondition(frame.minX >= -1 && frame.maxX <= window.bounds.maxX + 1)
        precondition(frame.minY >= -1 && frame.maxY <= window.bounds.maxY + 1)
        if !landscape {
            precondition(abs(frame.height - portraitSize.height) < 2 && abs(frame.width - portraitSize.width) < 2,
                         "Portrait popup differs from its original size: \(frame), expected \(portraitSize)")
        }
    }

    private func pause(_ milliseconds: Int) async { try? await Task.sleep(for: .milliseconds(milliseconds)) }

    private func requestOrientation(_ mask: UIInterfaceOrientationMask) {
        window!.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: mask)) { error in
            print("Orientation request failed: \(error)")
            fflush(stdout)
        }
    }

    private func saveScreenshot(name: String) {
        let window = window!
        let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        try! image.pngData()!.write(to: documents.appendingPathComponent("\(name).png"))
    }
}
