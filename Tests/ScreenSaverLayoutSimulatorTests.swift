// Compiles the production welcome screen with geometry probes and no network calls.
import SwiftUI
import UIKit

@MainActor enum ScreenSaverLayoutProbe {
    static var frames: [String: CGRect] = [:]
    static var displayedLayout = ""
}

@MainActor final class AppState: ObservableObject {
    @Published var screenSaverData: ScreenSaverData? = ScreenSaverData(
        welcomeText: ScreenSaverStrings.title,
        subtitle: ScreenSaverStrings.subtitle,
        actionButtonText: ScreenSaverStrings.actionButton,
        carouselImages: []
    )
    func warmScreenSaverData() async {}
}

enum HomeScreen { static func getCurrentTime() -> String { "12:00 PM" } }

private struct WelcomeFixture: View {
    @StateObject private var appState = AppState()
    @StateObject private var orientation = OrientationManager()

    var body: some View {
        ScreenSaver {}
            .environmentObject(appState)
            .environmentObject(orientation)
            .onGeometryChange(for: CGSize.self) { $0.size } action: { orientation.update(for: $0) }
    }
}

@main final class ScreenSaverLayoutTests: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        try? FileManager.default.removeItem(at: documents.appendingPathComponent("result.txt"))
        let window = UIWindow(frame: UIScreen.main.bounds)
        let host = UIHostingController(rootView: WelcomeFixture())
        window.rootViewController = host
        window.makeKeyAndVisible()
        self.window = window
        Screen.startMonitoring()

        Task { @MainActor in
            await pause(400)
            window.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            await pause(900)
            let baseline = ScreenSaverLayoutProbe.frames
            precondition(ScreenSaverLayoutProbe.displayedLayout == "portrait")
            precondition(baseline["heading"] != nil && baseline["subtitle"] != nil && baseline["button"] != nil)
            saveScreenshot(window, name: "portrait-before")
            print("BASELINE window=\(window.bounds.size), frames=\(baseline)")
            fflush(stdout)
            // A lingering keyboard inset can survive navigation/rotation even though
            // the welcome screen has no editable fields of its own.
            let input = UITextField(frame: CGRect(x: -100, y: 0, width: 80, height: 30))
            let keyboard = UIInputView(frame: CGRect(x: 0, y: 0, width: 800, height: 240), inputViewStyle: .keyboard)
            keyboard.heightAnchor.constraint(equalToConstant: 240).isActive = true
            input.inputView = keyboard
            host.view.addSubview(input)
            for cycle in 0..<12 {
                if cycle == 6 {
                    input.becomeFirstResponder()
                    await pause(700)
                    saveScreenshot(window, name: "portrait-keyboard-inset")
                    verifyPortrait(baseline, in: window, context: "keyboard shown")
                }
                for orientation: UIInterfaceOrientationMask in [.landscapeLeft, .portrait, .landscapeRight, .portrait] {
                    window.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
                    await pause(cycle.isMultiple(of: 2) ? 180 : 350)
                }
                await pause(550)
                precondition(window.bounds.width < window.bounds.height, "Must finish in portrait")
                verifyPortrait(baseline, in: window, context: "cycle-\(cycle + 1)")
                print("PASS rotation cycle \(cycle + 1), keyboard=\(cycle >= 6)")
                fflush(stdout)
            }
            input.resignFirstResponder()
            await pause(500)
            verifyPortrait(baseline, in: window, context: "keyboard dismissed")
            saveScreenshot(window, name: "portrait-after")
            // The shared portrait button wording is longer: keep it within the
            // landscape text column without overlapping the avatar or clipping.
            for orientation: UIInterfaceOrientationMask in [.landscapeLeft, .landscapeRight] {
                window.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
                await pause(900)
                precondition(window.bounds.width > window.bounds.height)
                precondition(ScreenSaverLayoutProbe.displayedLayout == "landscape")
                let button = ScreenSaverLayoutProbe.frames["landscapeButton"]!
                let avatar = ScreenSaverLayoutProbe.frames["landscapeAvatar"]!
                precondition(button.minX >= avatar.maxX, "Landscape button overlaps the avatar")
                precondition(button.maxX <= window.bounds.maxX && button.maxY <= window.bounds.maxY,
                             "Landscape button is clipped: \(button), window=\(window.bounds)")
            }
            saveScreenshot(window, name: "landscape-after")
            window.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            await pause(900)
            try! "PASS: Welcome screen returns to its original portrait geometry after 48 rotation requests, with and without keyboard insets.\n".write(
                to: documents.appendingPathComponent("result.txt"), atomically: true, encoding: .utf8
            )
            exit(0)
        }
        return true
    }

    func pause(_ milliseconds: Int) async { try? await Task.sleep(for: .milliseconds(milliseconds)) }

    func verifyPortrait(_ baseline: [String: CGRect], in window: UIWindow, context: String) {
        guard ScreenSaverLayoutProbe.displayedLayout == "portrait" else {
            saveScreenshot(window, name: "failed-\(context)")
            preconditionFailure("Wrong layout after \(context): \(ScreenSaverLayoutProbe.displayedLayout)")
        }
        for key in ["heading", "subtitle", "avatar", "button"] {
            guard let expected = baseline[key], let actual = ScreenSaverLayoutProbe.frames[key] else {
                preconditionFailure("Missing geometry for \(key)")
            }
            let matches = abs(expected.minX - actual.minX) < 1 && abs(expected.minY - actual.minY) < 1
                && abs(expected.width - actual.width) < 1 && abs(expected.height - actual.height) < 1
            if !matches { saveScreenshot(window, name: "failed-\(context)") }
            precondition(matches, "\(key) changed after \(context): expected \(expected), actual \(actual)")
        }
    }

    func saveScreenshot(_ window: UIWindow, name: String) {
        let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        try! image.pngData()!.write(to: documents.appendingPathComponent("\(name).png"))
    }
}
