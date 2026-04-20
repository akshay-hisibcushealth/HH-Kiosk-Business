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
    @State private var clientID = LocalUserStorage.loadClientID()

    var body: some View {
        ZStack {
            if clientID == nil {
                ClientIDEntryScreen { savedClientID in
                    clientID = savedClientID
                }
                .environmentObject(appState)
                .transition(.opacity)
            } else if appState.isBrandingLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.4)
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(AppColors.primary).ignoresSafeArea())
                    .transition(.opacity)
            } else {
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
        }
        .animation(.easeInOut(duration: 0.5), value: appState.showScreenSaver)
        .animation(.easeInOut(duration: 0.3), value: clientID == nil)
        .task(id: clientID) {
            if let clientID {
                await appState.loadBrandingData(for: clientID)
            } else {
                appState.clearBrandingData()
            }
        }
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
