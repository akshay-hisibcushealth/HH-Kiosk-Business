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
                PostSessionFlowScreen()
//             ResultsViewWrapper()
//                HomeScreen()
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
        let controller = ResultsViewController(appState: nil)
        // This will automatically call loadMockData() in viewDidLoad
        return controller
    }

    func updateUIViewController(_ uiViewController: ResultsViewController, context: Context) {
        // no-op
    }
}
