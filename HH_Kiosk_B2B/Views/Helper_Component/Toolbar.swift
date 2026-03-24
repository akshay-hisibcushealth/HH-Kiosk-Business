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
            Text(SharedViewStrings.Toolbar.companyLogoPlaceholder)
                .font(.system(size: 24.sp, weight: .semibold))
                .foregroundColor(Color(AppColors.white))
                .multilineTextAlignment(.center)
                .padding(.all, 24.w)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color(AppColors.white), lineWidth: 5.w)
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





struct ResultToolbar: View {
    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(Color(AppColors.toolbarLogoBackground))
                    .frame(width: 200.w, height: 90.h)
                    .padding()
                
                buildMediumText(SharedViewStrings.Toolbar.resultPartnerLogoPlaceholder, 24.sp, color: Color(AppColors.toolbarPlaceholderText))
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
