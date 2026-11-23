// Exercises the production toast with real simulator timing and no API calls.
import UIKit

@main
final class ScanSaveToastSimulatorTests: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let toast = ScanSaveToast()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let controller = UIViewController()
        controller.view.backgroundColor = .white
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        self.window = window

        Task { @MainActor in
            await pause(300)
            let view = controller.view!
            let start = ProcessInfo.processInfo.systemUptime
            toast.schedule(in: view) { true }
            await pause(1600)
            precondition(confirmation(in: view) == nil, "Toast appeared before the two-second delay")
            await waitForToast(in: view)
            let delay = ProcessInfo.processInfo.systemUptime - start
            precondition(delay >= 2 && delay < 3, "Unexpected toast delay: \(delay)")
            let banner = confirmation(in: view)!
            let label = banner.subviews.compactMap { $0 as? UILabel }.first!
            precondition(label.text == "Your results have been sent to your email!")
            view.layoutIfNeeded()
            precondition(banner.frame.minX >= 0 && banner.frame.maxX <= view.bounds.maxX)
            precondition(banner.frame.minY >= view.safeAreaInsets.top)
            saveScreenshot(window)
            print("PASS: Save confirmation appears after \(String(format: "%.2f", delay)) seconds with the correct message")
            fflush(stdout)

            await pause(4100)
            precondition(confirmation(in: view) == nil, "Toast did not dismiss after four seconds")
            print("PASS: Toast dismisses automatically")

            toast.schedule(in: view) { true }
            await pause(200)
            toast.cancel()
            await pause(2100)
            precondition(confirmation(in: view) == nil, "Cancelled toast appeared")
            print("PASS: Leaving or refreshing before the delay cancels presentation")

            var visible = false
            toast.schedule(in: view) { visible }
            await pause(2200)
            precondition(confirmation(in: view) == nil, "Toast appeared on hidden results")
            visible = true
            await pause(200)
            precondition(confirmation(in: view) == nil, "Old toast replayed on return")
            print("PASS: Hidden results suppress the toast without replaying it")

            toast.schedule(in: view) { true }
            await pause(1200)
            toast.schedule(in: view) { true }
            await pause(1100)
            precondition(confirmation(in: view) == nil, "An older save displayed a stale toast")
            await waitForToast(in: view)
            precondition(view.subviews.filter { $0.accessibilityIdentifier == "results.saveConfirmationToast" }.count == 1)
            toast.cancel()
            precondition(confirmation(in: view) == nil, "Visible toast survived cancellation")
            print("PASS: New saves replace pending confirmations; cancellation removes visible toasts")

            let detached = UIView(frame: view.bounds)
            toast.schedule(in: detached) { true }
            await pause(2200)
            precondition(confirmation(in: detached) == nil, "Toast appeared in a detached view")
            toast.cancel()
            let summary = "PASS: Two-second delay, save message, four-second dismissal, cancellation, hidden/detached screens, and replacement of pending confirmations.\n"
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            try! summary.write(to: documents.appendingPathComponent("result.txt"), atomically: true, encoding: .utf8)
            print(summary)
            fflush(stdout)
            exit(0)
        }
        return true
    }

    private func confirmation(in view: UIView) -> UIView? {
        view.subviews.first { $0.accessibilityIdentifier == "results.saveConfirmationToast" }
    }

    private func pause(_ milliseconds: Int) async {
        try? await Task.sleep(for: .milliseconds(milliseconds))
    }

    private func waitForToast(in view: UIView) async {
        for _ in 0..<40 {
            if confirmation(in: view) != nil { return }
            await pause(50)
        }
        preconditionFailure("Expected save confirmation did not appear")
    }

    private func saveScreenshot(_ window: UIWindow) {
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let image = renderer.image { _ in window.drawHierarchy(in: window.bounds, afterScreenUpdates: true) }
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try! image.pngData()!.write(to: documents.appendingPathComponent("save-confirmation.png"))
    }
}
