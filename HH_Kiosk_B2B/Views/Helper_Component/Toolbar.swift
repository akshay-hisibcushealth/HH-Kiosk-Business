import SwiftUI

struct Toolbar: View {
    @EnvironmentObject private var orientation: OrientationManager
    private var contentScale: CGFloat { orientation.isLandscape ? 0.8 : 1 }
    // For updating time in the toolbar
    @State private var currentTime: String = HomeScreen.getCurrentTime()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            Image(AppIconNames.Asset.logo)
                .resizable()
                .scaledToFit()
                .frame(width: 200.w * contentScale, height: 140.h * contentScale)
                .padding([.vertical], 16.h * contentScale)

            Spacer()

            BrandedCompanyLogoView(contentScale: contentScale)

            Spacer()

            DateTimeView(contentScale: contentScale)
        }
        .padding(.horizontal, 24.w * contentScale)
        .padding(.vertical, 10.h * contentScale)
        .background(Color(AppColors.primary))
        .onReceive(timer) { _ in
            currentTime = HomeScreen.getCurrentTime()
        }
    }
}

struct ResultToolbar: View {
    var isLandscape = false
    private var contentScale: CGFloat { isLandscape ? 0.8 : 1 }
    var body: some View {
        HStack {
            Image(AppIconNames.Asset.poweredByHHLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 220.w * contentScale, height: 140.h * contentScale)
                .padding(.vertical, 48.h * contentScale)
                .padding(.trailing, 32.h * contentScale)
            Spacer()
            BrandedCompanyLogoView(contentScale: contentScale)
          
        }
        .padding(.horizontal, 24.w * contentScale)
        .background(Color(AppColors.primary))
    }
}

private struct BrandedCompanyLogoView: View {
    var contentScale: CGFloat = 1

    var body: some View {
        Text(SharedViewStrings.Toolbar.companyLogoPlaceholder)
            .font(.system(size: 24.sp * contentScale, weight: .semibold))
            .foregroundColor(Color(AppColors.white))
            .multilineTextAlignment(.center)
            .padding(.all, 24.w * contentScale)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color(AppColors.white), lineWidth: 5.w * contentScale)
            )
    }
}
