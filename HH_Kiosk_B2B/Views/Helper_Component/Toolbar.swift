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
            BrandedCompanyLogoView()
            Spacer()
            Image(AppIconNames.Asset.poweredByHHLogo)
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

private struct BrandedCompanyLogoView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if let logoURLString = appState.brandingData?.brandingInfo.logo,
           let logoURL = URL(string: logoURLString) {
            if let cachedUIImage = CachedImageLookup.image(for: logoURL) {
                Image(uiImage: cachedUIImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280.w, height: 110.h)
                    .padding(.horizontal, 12.w)
                    .padding(.vertical, 8.h)
                    .background(Color.clear)
            } else {
                CachedAsyncImage(
                    url: logoURL,
                    width: 280.w,
                    height: 110.h,
                    cornerRadius: 0
                ) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 12.w)
                        .padding(.vertical, 8.h)
                }
                .background(Color.clear)
            }
        } else {
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
}
