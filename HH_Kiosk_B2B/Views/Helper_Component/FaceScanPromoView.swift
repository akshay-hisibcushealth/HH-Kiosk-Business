import SwiftUI

struct FaceScanPromoView: View {
    @Binding var isNavigating: Bool
    @State private var showWebView = false

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text("Curious About Your Health?")
                    .foregroundColor(.white)
                    .font(.title)
                    .fontWeight(.regular)

                Text("Start with a 30s Face Scan")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding()

            Spacer()

            VStack(alignment: .center) {
                Button(action: {
                    isNavigating = true
                }) {
                    Image("scan_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280, height: 80)
                        .padding(.top, 16)
                }

                Button(action: {
                    showWebView = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                        Text("Watch quick Demo")
                            .foregroundColor(.white)
                            .underline()
                    }
                }
            }
            .padding()
        }
        .padding()
        .background(Color(red: 1, green: 69/255, blue: 0))
        .sheet(isPresented: $showWebView) {
                   WebViewSheetView(url: URL(string: "https://drive.google.com/file/d/1dPJs1A6aptEh3yTCVxR5BUlRfyLWa3rL/view?usp=sharing")!)
               }
        
    }
}

