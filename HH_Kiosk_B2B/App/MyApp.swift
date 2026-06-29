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
    @StateObject private var faceManager = FaceScanManager()
    @State private var isShowingPhysicalAttributes = false

    var body: some View {
        ZStack {
            if isShowingPhysicalAttributes {
                PhysicalAttributesScreen()
                    .environmentObject(appState)
                    .environmentObject(faceManager)
                    .transition(.opacity)
                    .zIndex(1)
            } else {
                ScreenSaver {
                    isShowingPhysicalAttributes = true
                }
                    .environmentObject(appState)
                    .transition(.opacity)
                    .zIndex(0)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isShowingPhysicalAttributes)
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
