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
    @State private var showResponseReceivedToast = false

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
//             ResultsViewWrapper()
                    HomeScreen()
                        .environmentObject(appState)
                        .transition(.opacity)
                        .zIndex(0)
                }
            }

        }
        .overlay(alignment: .top) {
            if showResponseReceivedToast {
                ResponseReceivedToast()
                    .padding(.top, 214.h)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(3)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.showScreenSaver)
        .animation(.easeInOut(duration: 0.3), value: clientID == nil)
        .onAppear {
            presentResponseReceivedToastIfReady()
        }
        .onChange(of: appState.isBrandingLoading) { _, _ in
            presentResponseReceivedToastIfReady()
        }
        .onChange(of: appState.showScreenSaver) { _, _ in
            presentResponseReceivedToastIfReady()
        }
        .task(id: clientID) {
            if let clientID {
                await appState.loadBrandingData(for: clientID)
            } else {
                appState.clearBrandingData()
            }
        }
    }

    private func presentResponseReceivedToastIfReady() {
        guard clientID != nil,
              !appState.isBrandingLoading,
              appState.brandingData != nil || appState.brandingErrorMessage != nil,
              !appState.showScreenSaver,
              UserDefaults.standard.bool(forKey: AppStorageKeys.responseReceivedToastPending) else {
            return
        }

        UserDefaults.standard.removeObject(forKey: AppStorageKeys.responseReceivedToastPending)

        withAnimation(.easeOut(duration: 0.25)) {
            showResponseReceivedToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeIn(duration: 0.2)) {
                showResponseReceivedToast = false
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
