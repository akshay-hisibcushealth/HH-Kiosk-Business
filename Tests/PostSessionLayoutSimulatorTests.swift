// The runner compiles the production screen with geometry observers; side effects are stubbed.
import SwiftUI
import UIKit

@MainActor enum PostSessionLayoutProbe {
    static var showsNPS = false
    static var footer = CGRect.zero
    static var viewport = CGRect.zero
}

// No network calls, stored user data, navigation, or privacy changes in this fixture.
struct KioskNextStepResponse { let id: Int; let title: String; let description: String }
protocol KioskSubmissionServiceProtocol {
    func sendUserResponse(email: String, nextSteps: [KioskNextStepResponse], npsScore: Int?) async throws
}
struct KioskSubmissionService: KioskSubmissionServiceProtocol {
    func sendUserResponse(email: String, nextSteps: [KioskNextStepResponse], npsScore: Int?) async throws {}
}
enum LocalUserStorage { static func loadEmail() -> String? { nil } }
enum AppAPIError: Error { case missingSavedUser }
enum SensitiveScreenPrivacy {
    static func beginProtecting(owner: String) {}
    static func endProtecting(owner: String) {}
}
func navigateBackFromPostSessionFlow() {}
func navigateToHome(showResponseToast: Bool) {}
enum HomeScreen { static func getCurrentTime() -> String { "12:00 PM" } }

@main final class PostSessionLayoutTests: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        try? FileManager.default.removeItem(at: documents.appendingPathComponent("result.txt"))
        let window = UIWindow(frame: UIScreen.main.bounds)
        let presenter = UIViewController()
        window.rootViewController = presenter
        window.makeKeyAndVisible()
        self.window = window
        Task { @MainActor in
            await pause(400)
            for nps in [false, true] {
                PostSessionLayoutProbe.showsNPS = nps
                let host = UIHostingController(rootView: PostSessionFlowScreen())
                host.safeAreaRegions = .container
                host.modalPresentationStyle = .fullScreen
                presenter.present(host, animated: false)
                await pause(500)
                // A real keyboard exercises the same safe-area pressure as a stale
                // keyboard inset. Neither survey step should react to that inset.
                let input = UITextField(frame: CGRect(x: -100, y: 0, width: 80, height: 30))
                let keyboard = UIInputView(frame: CGRect(x: 0, y: 0, width: 800, height: 308), inputViewStyle: .keyboard)
                keyboard.heightAnchor.constraint(equalToConstant: 308).isActive = true
                input.inputView = keyboard
                host.view.addSubview(input)
                for keyboardVisible in [false, true] {
                    if keyboardVisible { input.becomeFirstResponder(); await pause(500) }
                    for finalOrientation: UIInterfaceOrientationMask in [.portrait, .landscapeRight] {
                        for orientation: UIInterfaceOrientationMask in [.landscapeLeft, .portrait, .landscapeRight, .portrait, finalOrientation] {
                            window.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
                            await pause(180)
                        }
                        await pause(700)
                        precondition((window.bounds.width > window.bounds.height) == (finalOrientation != .portrait), "Rotation must reach the requested orientation")
                        let footer = PostSessionLayoutProbe.footer
                        let viewport = PostSessionLayoutProbe.viewport
                        let expectedBottom = window.bounds.maxY - window.safeAreaInsets.bottom
                        precondition(abs(footer.maxY - expectedBottom) < 2, "Footer detached after rotation: footer=\(footer), expectedBottom=\(expectedBottom), keyboard=\(keyboardVisible), nps=\(nps)")
                        precondition(abs(viewport.maxY - footer.minY) < 2, "Scroll area must end above the footer: \(viewport), \(footer)")
                        precondition(footer.minX >= -1 && footer.maxX <= window.bounds.maxX + 1, "Footer must fit current width")
                        precondition(viewport.height > 0, "Content viewport must remain usable")
                        let scroll = descendants(host.view).compactMap { $0 as? UIScrollView }.first!
                        let bottom = max(0, scroll.contentSize.height - scroll.bounds.height + scroll.adjustedContentInset.bottom)
                        scroll.setContentOffset(CGPoint(x: 0, y: bottom), animated: false)
                        await pause(100)
                        precondition(abs(PostSessionLayoutProbe.footer.minY - footer.minY) < 1, "Scrolling must not move footer")
                        print("PASS nps=\(nps), keyboard=\(keyboardVisible), window=\(window.bounds.size), footer=\(footer)")
                        fflush(stdout)
                    }
                }
                input.resignFirstResponder()
                await pause(400)
                presenter.dismiss(animated: false)
                await pause(400)
            }
            try! "PASS: Next Steps and NPS footers remain at the bottom after rapid rotations and scrolling, with and without keyboard safe-area pressure.\n".write(to: documents.appendingPathComponent("result.txt"), atomically: true, encoding: .utf8)
            exit(0)
        }
        return true
    }
    func pause(_ milliseconds: Int) async { try? await Task.sleep(for: .milliseconds(milliseconds)) }
    func descendants(_ view: UIView) -> [UIView] { [view] + view.subviews.flatMap(descendants) }
}
