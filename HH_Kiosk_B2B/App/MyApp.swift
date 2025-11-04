import SwiftUI


@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}


import SwiftUI

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
                ResultsViewWrapper()
//                HomeScreen()
//                    .environmentObject(appState)
                    .transition(.opacity)
                    .zIndex(0)
            }
        }
        // Animate the view change
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

