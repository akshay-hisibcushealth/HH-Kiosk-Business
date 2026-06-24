import SwiftUI
import UIKit
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
    @Environment(\.dismiss) var dismiss
    let url: URL
    private let maxPopupWidth: CGFloat = 1200
    private let maxPopupHeight: CGFloat = 900

    var body: some View {
        NavigationView {
            WebView(url: url)
                .navigationBarTitle(SharedViewStrings.WebView.faceScanDemoTitle, displayMode: .inline)
                .navigationBarItems(leading:
                    Button(SharedViewStrings.WebView.doneButtonTitle) {
                        dismiss()
                    }
                )
        }
        .frame(
            width: min(UIScreen.main.bounds.width * 0.9, maxPopupWidth),
            height: min(UIScreen.main.bounds.height * 0.9, maxPopupHeight)
        )
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
