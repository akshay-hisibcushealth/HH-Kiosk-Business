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
    @Environment(\.dismiss) var dismiss
    let url: URL

    var body: some View {
        NavigationView {
            WebView(url: url)
                .navigationBarTitle("Face Scan Demo", displayMode: .inline)
                .navigationBarItems(leading:
                    Button("Done") {
                        dismiss()
                    }
                )
        }
    }
}
