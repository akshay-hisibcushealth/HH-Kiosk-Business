import SwiftUI

struct HealthJourneyButton: View {
    @EnvironmentObject var appState: AppState
    // MARK: - Parameters with default values
    var text: String = ScreenSaverStrings.actionButton
    var backgroundColor: Color = Color(AppColors.accent)
    var textColor: Color = Color(AppColors.white)
    var icon: String = AppIconNames.SvgAsset.smile
    
    var body: some View {
            Button(action: {
                withAnimation {
                    appState.dismissScreenSaver()
                }
            }) {
                HStack {
                    assetSVG(icon,tintColor: textColor)
                        .scaledToFit()
                        .frame(width: 48.w, height: 48.h)
                        .foregroundColor(textColor)
                        .padding(.leading, 64.w)
                        .padding(.trailing, 32.w)
                    
                    Text(text)
                        .font(.system(size: 32.sp, weight: .semibold))
                        .foregroundColor(textColor)
                        .padding(.trailing, 64.w)
                }
                .padding(.vertical, 32.h)
                .background(backgroundColor)
                .cornerRadius(200.r)
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
