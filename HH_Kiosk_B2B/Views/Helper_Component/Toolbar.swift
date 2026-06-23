import SwiftUI

struct Toolbar: View {
    // For updating time in the toolbar
    @State private var currentTime: String = HomeScreen.getCurrentTime()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            Image(AppIconNames.Asset.logo)
                .resizable()
                .scaledToFit()
                .frame(width: 200.w, height: 140.h)
                .padding([.vertical], 16.h)

            Spacer()

            BrandedCompanyLogoView()

            Spacer()

            DateTimeView()
        }
        .padding(.horizontal, 24.w)
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
            Image(AppIconNames.Asset.poweredByHHLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 220.w, height: 140.h)
                .padding(.vertical, 48.h)
                .padding(.trailing, 32.h)
            Spacer()
            BrandedCompanyLogoView()
          
        }
        .padding(.horizontal, 24.w)
        .background(Color(AppColors.primary))
    }
}

private struct BrandedCompanyLogoView: View {
    var body: some View {
        Image(AppIconNames.Asset.axoLogo)
            .resizable()
            .scaledToFit()
            .frame(width: 220.w)
//        Text(SharedViewStrings.Toolbar.companyLogoPlaceholder)
//            .font(.system(size: 24.sp, weight: .semibold))
//            .foregroundColor(Color(AppColors.white))
//            .multilineTextAlignment(.center)
//            .padding(.all, 24.w)
//            .overlay(
//                RoundedRectangle(cornerRadius: 0)
//                    .stroke(Color(AppColors.white), lineWidth: 5.w)
//            )
    }
}
