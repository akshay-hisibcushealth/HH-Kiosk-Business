import SwiftUI

struct HealthJourneyButton: View {
    @EnvironmentObject var appState: AppState
    // MARK: - Parameters with default values
    var text: String = ScreenSaverStrings.actionButton
    var backgroundColor: Color = Color(AppColors.ctaGreen)
    var textColor: Color = Color(AppColors.ctaContent)
    var icon: String = AppIconNames.SvgAsset.smile
    
    var body: some View {
        Button(action: {
            withAnimation {
                appState.dismissScreenSaver()
            }
        }) {
            HStack(spacing: 24.w) {
                assetSVG(icon, tintColor: textColor)
                    .scaledToFit()
                    .frame(width: 52.w, height: 52.h)
                    .foregroundColor(textColor)

                Text(text)
                    .font(.system(size: 38.sp, weight: .bold))
                    .foregroundColor(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 24.w)

                Image(systemName: AppIconNames.Symbol.arrowRight)
                    .font(.system(size: 36.sp, weight: .regular))
                    .foregroundColor(textColor)
                    .frame(width: 82.w, height: 82.w)
                    .background(textColor.opacity(0.18))
                    .clipShape(Circle())
            }
            .padding(.leading, 70.w)
            .padding(.trailing, 24.w)
            .frame(width: 1050.w, height: 142.h)
            .background(backgroundColor)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}


struct HealthJourneyButtonFaceScanPromoView: View {
    // MARK: - Parameters with default values
    var text: String = HomeScreenStrings.Promo.tryFaceScan
    var backgroundColor: Color = Color(AppColors.white)
    var textColor: Color = Color(AppColors.primary)
    var icon: String = AppIconNames.SvgAsset.smile
    let action: () -> Void
    
    var body: some View {
            Button(action: action) {
                HStack {
                    assetSVG(icon,tintColor: textColor)
                        .scaledToFit()
                        .frame(width: 32.w, height: 32.h)
                        .foregroundColor(textColor)
                        .padding(.leading, 32.w)
                        .padding(.trailing, 16.w)
                    
                    Text(text)
                        .font(.system(size: 32.sp, weight: .semibold))
                        .foregroundColor(textColor)
                        .padding(.trailing, 32.w)
                }
                .padding(.vertical, 20.h)
                .background(backgroundColor)
                .cornerRadius(200.r)
            }
            .buttonStyle(.plain)
            
        
    }
}
