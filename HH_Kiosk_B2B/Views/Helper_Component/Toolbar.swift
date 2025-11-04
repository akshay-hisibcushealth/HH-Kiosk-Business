import SwiftUI

struct Toolbar: View {
    // For updating time in the toolbar
    @State private var currentTime: String = HomeScreen.getCurrentTime()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    var body: some View {
        HStack {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200.w, height: 140.h)
                .padding([.vertical], 16.h)
            
            Spacer()
            // White bordered box with text
            Text("PUT YOUR COMPANY\nLOGO HERE")
                .font(.system(size: 24.sp, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.all, 24.w)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.white, lineWidth: 5.w)
                )
            
            Spacer()
            
            DateTimeView()
        }
        .padding(.horizontal,24.w)
        .padding(.vertical, 10.h)
        .background(Color(AppColors.primary))
        .onReceive(timer) { _ in
            currentTime = HomeScreen.getCurrentTime()
        }
        
    }
}


