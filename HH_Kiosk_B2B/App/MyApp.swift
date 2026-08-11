import SwiftUI


@main
struct MyApp: App {
    @StateObject private var orientation = OrientationManager()
    init() {
          Screen.startMonitoring()
      }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(orientation)
        }
    }
}


struct RootView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        ZStack {
            if appState.showScreenSaver {
                ScreenSaver()
                    .environmentObject(appState)
                    .transition(.opacity)
                    .zIndex(1)
            } else {
//             ResultsViewWrapper()
                HomeScreen()
                    .environmentObject(appState)
                    .transition(.opacity)
                    .zIndex(0)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.showScreenSaver)
        .onAppear {
            if UIApplication.shared.applicationState != .active {
                PrivacyScreenShield.show()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            PrivacyScreenShield.show()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            PrivacyScreenShield.hide()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { _ in
            SensitiveScreenPrivacy.refreshCaptureProtection()
        }
    }
}

@MainActor
enum SensitiveScreenPrivacy {
    private static let viewTag = 9_814_727
    private static var activeOwners: Set<String> = []

    static func beginProtecting(owner: String) {
        activeOwners.insert(owner)
        refreshCaptureProtection()
    }

    static func endProtecting(owner: String) {
        activeOwners.remove(owner)
        refreshCaptureProtection()
    }

    static func refreshCaptureProtection() {
        let shouldHideSensitiveContent = !AppConfig.screenCaptureEnabled
            && !activeOwners.isEmpty
            && UIScreen.main.isCaptured

        for window in visibleWindows {
            if shouldHideSensitiveContent {
                guard window.viewWithTag(viewTag) == nil else { continue }
                let shield = UIView(frame: window.bounds)
                shield.tag = viewTag
                shield.backgroundColor = .white
                shield.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                shield.isUserInteractionEnabled = true
                shield.accessibilityIdentifier = "sensitive-screen-capture-shield"
                window.addSubview(shield)
            } else {
                window.viewWithTag(viewTag)?.removeFromSuperview()
            }
        }
    }

    private static var visibleWindows: [UIWindow] {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .filter { !$0.isHidden }
    }
}

@MainActor
private enum PrivacyScreenShield {
    private static let viewTag = 9_814_726

    static func show() {
        for window in visibleWindows where window.viewWithTag(viewTag) == nil {
            let shield = UIView(frame: window.bounds)
            shield.tag = viewTag
            shield.backgroundColor = .white
            shield.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            shield.isUserInteractionEnabled = true
            shield.accessibilityIdentifier = "privacy-screen-shield"
            window.addSubview(shield)
        }
    }

    static func hide() {
        for window in visibleWindows {
            window.viewWithTag(viewTag)?.removeFromSuperview()
        }
    }

    private static var visibleWindows: [UIWindow] {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .filter { !$0.isHidden }
    }
}



struct ResultsViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ResultsViewController {
        let controller = ResultsViewController(appState: nil)
        // This will automatically call loadMockData() in viewDidLoad
        return controller
    }

    func updateUIViewController(_ uiViewController: ResultsViewController, context: Context) {
        // no-op
    }
}
