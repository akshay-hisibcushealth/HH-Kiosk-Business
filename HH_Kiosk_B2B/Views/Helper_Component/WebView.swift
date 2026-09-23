import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}


struct WebViewSheetView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) var dismiss
    let url: URL

    private let screenSaverSuppressionReason = "faceScanDemo.fullScreen"

    var body: some View {
        NavigationStack {
            WebView(url: url)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle(SharedViewStrings.WebView.faceScanDemoTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(SharedViewStrings.WebView.doneButtonTitle) {
                            dismiss()
                        }
                    }
                }
        }
        .onAppear {
            appState.setScreenSaverSuppressed(true, reason: screenSaverSuppressionReason)
        }
        .onDisappear {
            appState.setScreenSaverSuppressed(false, reason: screenSaverSuppressionReason)
        }
    }
}
