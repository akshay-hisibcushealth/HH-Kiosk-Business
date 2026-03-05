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
        }
    }
}


struct RootView: View {
    @EnvironmentObject var orientation: OrientationManager
    @StateObject private var appState = AppState()

    var body: some View {
        ZStack {
            if appState.showScreenSaver {
                ScreenSaver()
                    .environmentObject(appState)
                    .transition(.opacity)
                    .zIndex(1)
            } else {
//         ResultsViewWrapper()
                HomeScreen()
                    .environmentObject(appState)
                    .transition(.opacity)
                    .zIndex(0)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.showScreenSaver)
    }
}



struct ResultsViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ResultsViewController {
        let controller = ResultsViewController()
        // This will automatically call loadMockData() in viewDidLoad
        return controller
    }

    func updateUIViewController(_ uiViewController: ResultsViewController, context: Context) {
        // no-op
    }
}

