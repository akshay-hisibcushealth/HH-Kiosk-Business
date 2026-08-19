import SwiftUI

struct HealthJourneyButton: View {
    // MARK: - Parameters with default values
    var text: String = ScreenSaverStrings.actionButton
    var textColor: Color = Color(AppColors.white)
    var icon: String = AppIconNames.SvgAsset.smile
    let action: () -> Void
    
    var body: some View {
            Button(action: action) {
                HStack(spacing: 34.w) {
                    assetSVG(icon,tintColor: textColor)
                        .scaledToFit()
                        .frame(width: 52.w, height: 52.h)
                        .foregroundColor(textColor)
                    
                    Text(text)
                        .font(.system(size: 42.sp, weight: .bold))
                        .foregroundColor(textColor)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .minimumScaleFactor(0.72)
                        .layoutPriority(1)

                    Image(systemName: AppIconNames.Symbol.arrowRight)
                        .font(.system(size: 34.sp, weight: .regular))
                        .foregroundColor(textColor)
                        .frame(width: 88.w, height: 88.h)
                        .background(textColor.opacity(0.20))
                        .clipShape(Circle())
                }
                .padding(.leading, 70.w)
                .padding(.trailing, 32.w)
                .frame(minWidth: 600.w, minHeight: 130.h)
                .fixedSize(horizontal: true, vertical: false)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.22, blue: 0.02),
                            Color(red: 1.0, green: 0.34, blue: 0.04),
                            Color(red: 1.0, green: 0.55, blue: 0.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color(red: 1.0, green: 0.45, blue: 0.0).opacity(0.34), radius: 28, x: 0, y: 22)
            }
            .buttonStyle(.plain)
            
        
    }
}


struct HealthJourneyButtonFaceScanPromoView: View {
    // MARK: - Parameters with default values
    var text: String = HomeScreenStrings.Promo.tryFaceScan
    var backgroundColor: Color = Color(AppColors.white)
    var textColor: Color = Color(AppColors.accent)
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
