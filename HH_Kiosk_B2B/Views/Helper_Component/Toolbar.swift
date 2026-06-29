import SwiftUI

struct Toolbar: View {
    var body: some View {
        ResultToolbar()
    }
//    // For updating time in the toolbar
//    @State private var currentTime: String = HomeScreen.getCurrentTime()
//    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
//
//    var body: some View {
//        HStack {
//            Image(AppIconNames.Asset.logo)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 190.w, height: 140.h)
//                .padding([.vertical], 16.h)
//
//            Spacer()
//
//            BrandedCompanyLogoView()
//
//            Spacer()
//
//            DateTimeView()
//        }
//        .padding(.horizontal, 24.w)
//        .padding(.vertical, 10.h)
//        .background(Color(AppColors.primary))
//        .onReceive(timer) { _ in
//            currentTime = HomeScreen.getCurrentTime()
//        }
//    }
}

struct ResultToolbar: View {
    var isTransparent: Bool = false

    var body: some View {
        HStack {
            Image(AppIconNames.Asset.logo)
                .resizable()
                .scaledToFit()
                .frame(width: 190.w, height: 140.h)
                .padding(.vertical, 48.h)
                .padding(.trailing, 32.h)
            Spacer()
            BrandedCompanyLogoViewPlaceHolder()
          
        }
        .padding(.horizontal, 24.w)
        .background(isTransparent ? Color.clear : Color(AppColors.primary))
    }
}

private struct BrandedCompanyLogoView: View {
    var body: some View {
        Image(AppIconNames.Asset.axoLogo)
            .resizable()
            .scaledToFit()
            .frame(width: 300.w)
    }
}
private struct BrandedCompanyLogoViewPlaceHolder: View {
    var body: some View {
        Text(SharedViewStrings.Toolbar.companyLogoPlaceholder)
            .font(.system(size: 24.sp, weight: .semibold))
            .foregroundColor(Color(AppColors.white))
            .multilineTextAlignment(.center)
            .padding(.all, 24.w)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color(AppColors.white), lineWidth: 5.w)
            )
    }
}
    
