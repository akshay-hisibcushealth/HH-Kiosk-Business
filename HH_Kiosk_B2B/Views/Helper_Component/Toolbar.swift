import SwiftUI

struct Toolbar: View {
    // For updating time in the toolbar
    @State private var currentTime: String = HomeScreen.getCurrentTime()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    var body: some View {
        HStack {
            Image("logo_blue")
                .resizable()
                .scaledToFit()
                .frame(width: 200.w, height: 140.h)
                .padding([.vertical], 16.h)
            
            Spacer()
            Image("ucf_logo_horizontal")
                .resizable()
                .scaledToFit()
                .frame(width: 300.w, height: 180.h)
                .padding([.vertical], 16.h)
            
            Spacer()
            
            DateTimeView()
        }
        .padding(.horizontal,24.w)
        .padding(.vertical, 10.h)
        .background(
            Color(AppColors.white)
                .overlay(
                    VStack {
                        Spacer()
                        
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.15),
                                Color.black.opacity(0.05),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 20) // 👈 control shadow height
                    }
                )
        )
        .onReceive(timer) { _ in
            currentTime = HomeScreen.getCurrentTime()
        }
        
    }
}





struct ResultToolbar: View {
    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(Color(AppColors.toolbarLogoBackground))
                    .frame(width: 200.w, height: 90.h)
                    .padding()
                
                buildMediumText("Partner logo\ngoes  here", 24.sp, color: Color(AppColors.toolbarPlaceholderText))
                    .padding()
                
            }
            Spacer()
            Image("powered_by_hh_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 220.w, height: 140.h)
                .padding(.vertical, 48.h)
                .padding(.trailing, 32.h)
        }
        .padding(.horizontal, 24.w)
        .background(Color(AppColors.primary))
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 52.r, bottomTrailingRadius: 52.r))
    }
    
}
