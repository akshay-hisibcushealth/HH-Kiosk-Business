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
            let success = decodeDelivery(#"{"report_email_sent":true,"message":"Your results have been sent to your mail!","final_results":{"report_email_sent":false,"message":"Stale nested message","HR_BPM":93}}"#)
            let failure = decodeDelivery(#"{"report_email_sent":false,"message":"Unable to email your results. Please contact kiosk support.","final_results":{"report_email_sent":true,"message":"Stale nested success","HR_BPM":93}}"#)
            precondition(success.sent && !failure.sent, "Only top-level email flags control delivery status")
            for json in [
                #"{"final_results":{"report_email_sent":true,"message":"Nested only"}}"#,
                #"{"report_email_sent":null,"message":"Unknown"}"#,
                #"{"report_email_sent":"true","message":"Invalid type"}"#,
                #"{"report_email_sent":1,"message":"Invalid type"}"#,
                #"{"report_email_sent":true,"message":null}"#,
                #"{"report_email_sent":true}"#
            ] {
                precondition((try? JSONDecoder().decode(ReportEmailDelivery.self, from: Data(json.utf8))) == nil,
                             "Missing or invalid metadata must not invent an email outcome")
            }
            print("PASS: Top-level flags override conflicting nested values; incomplete metadata is rejected")
            await pause(300)
            let view = controller.view!
            let start = ProcessInfo.processInfo.systemUptime
            toast.schedule(in: view, delivery: success) { true }
            await pause(1600)
            precondition(confirmation(in: view) == nil, "Toast appeared before the two-second delay")
            await waitForToast(in: view)
            let delay = ProcessInfo.processInfo.systemUptime - start
            precondition(delay >= 2 && delay < 3, "Unexpected toast delay: \(delay)")
            let banner = confirmation(in: view)!
            let label = banner.subviews.compactMap { $0 as? UILabel }.first!
            precondition(label.text == "Your results have been sent to your mail!")
            precondition(banner.backgroundColor == UIColor(red: 0.39, green: 0.76, blue: 0, alpha: 1))
            view.layoutIfNeeded()
            precondition(banner.frame.minX >= 0 && banner.frame.maxX <= view.bounds.maxX)
            precondition(banner.frame.minY >= view.safeAreaInsets.top)
            saveScreenshot(window, name: "save-confirmation")
            print("PASS: Green toast appears after \(String(format: "%.2f", delay)) seconds with the exact API message")
            fflush(stdout)

            await pause(4100)
            precondition(confirmation(in: view) == nil, "Toast did not dismiss after four seconds")
            print("PASS: Toast dismisses automatically")

            toast.schedule(in: view, delivery: failure) { true }
            await pause(2100)
            await waitForToast(in: view)
            let failureBanner = confirmation(in: view)!
            precondition(failureBanner.backgroundColor == .systemRed)
            precondition(failureBanner.subviews.compactMap { $0 as? UILabel }.first?.text == failure.message)
            view.layoutIfNeeded()
            precondition(view.bounds.contains(failureBanner.frame))
            saveScreenshot(window, name: "email-failure")
            print("PASS: Red toast displays the exact top-level failure message despite nested success")
            toast.cancel()

            toast.schedule(in: view, delivery: success) { true }
            await pause(200)
            toast.cancel()
            await pause(2100)
            precondition(confirmation(in: view) == nil, "Cancelled toast appeared")
            print("PASS: Leaving or refreshing before the delay cancels presentation")

            var visible = false
            toast.schedule(in: view, delivery: success) { visible }
            await pause(2200)
            precondition(confirmation(in: view) == nil, "Toast appeared on hidden results")
            visible = true
            await pause(200)
            precondition(confirmation(in: view) == nil, "Old toast replayed on return")
            print("PASS: Hidden results suppress the toast without replaying it")

            toast.schedule(in: view, delivery: success) { true }
            await pause(1200)
            toast.schedule(in: view, delivery: failure) { true }
            await pause(1100)
            precondition(confirmation(in: view) == nil, "An older save displayed a stale toast")
            await waitForToast(in: view)
            precondition(view.subviews.filter { $0.accessibilityIdentifier == "results.saveConfirmationToast" }.count == 1)
            precondition(confirmation(in: view)?.backgroundColor == .systemRed,
                         "Replacing a pending success must present only the latest failure")
            toast.cancel()
            precondition(confirmation(in: view) == nil, "Visible toast survived cancellation")
            print("PASS: New saves replace pending confirmations; cancellation removes visible toasts")

            let detached = UIView(frame: view.bounds)
            toast.schedule(in: detached, delivery: success) { true }
            await pause(2200)
            precondition(confirmation(in: detached) == nil, "Toast appeared in a detached view")
            toast.cancel()
            toast.schedule(in: view, delivery: ReportEmailDelivery(sent: false, message: " \n ")) { true }
            await pause(2200)
            precondition(confirmation(in: view) == nil, "Empty API messages must not display a blank toast")
            let summary = "PASS: Top-level-only email status, exact API messages, green/red toasts, two-second delay, four-second dismissal, cancellation, hidden/detached screens, blank messages, and replacement of pending confirmations.\n"
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

    private func decodeDelivery(_ json: String) -> ReportEmailDelivery {
        try! JSONDecoder().decode(ReportEmailDelivery.self, from: Data(json.utf8))
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

    private func saveScreenshot(_ window: UIWindow, name: String) {
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let image = renderer.image { _ in window.drawHierarchy(in: window.bounds, afterScreenUpdates: true) }
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try! image.pngData()!.write(to: documents.appendingPathComponent("\(name).png"))
    }
}
