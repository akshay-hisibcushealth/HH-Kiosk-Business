import SwiftUI

struct PrivacyMessageView: View {
    @State private var showWebView = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Face Scan Results")
                .font(.largeTitle)
                .bold()
                .padding(.horizontal, 48)
                .padding(.top, 32)

            HStack(alignment: .center, spacing: 16) {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                    .alignmentGuide(.firstTextBaseline) { d in d[VerticalAlignment.top] }

                Text("The results from this face scan are not intended to diagnose, treat, or replace professional medical advice. For any health concerns, please consult a healthcare provider.")
                    .font(.title3)
                    .italic()
                    .foregroundColor(.blue)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            .padding(.leading, 32)
            .padding(.trailing, 16)
            .padding(.top, 16)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sheet(isPresented: $showWebView) {
                   WebViewSheetView(url: URL(string: "https://hibiscushealth.com/")!)
               }
    }
}
