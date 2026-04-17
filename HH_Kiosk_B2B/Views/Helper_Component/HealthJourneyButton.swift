import SwiftUI

struct HealthJourneyButton: View {
    @EnvironmentObject var appState: AppState
    // MARK: - Parameters with default values
    var text: String = ScreenSaverStrings.actionButton
    var backgroundColor: Color = Color(AppColors.ctaGreen)
    var textColor: Color = .white
    var icon: String = AppIconNames.Asset.scanFace
    
    var body: some View {
            Button(action: {
                withAnimation {
                    appState.dismissScreenSaver()
                }
            }) {
                HStack {
                    Image(icon)
                        .resizable()
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
