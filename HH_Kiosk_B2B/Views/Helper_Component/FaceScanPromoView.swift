import SwiftUI

struct FaceScanPromoView: View {
    @EnvironmentObject private var appState: AppState
    @Binding var isNavigating: Bool
    @State private var showWebView = false

    private let quickDemoSuppressionReason = "home.quickDemoSheet"

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                buildSemiBoldText(HomeScreenStrings.Promo.title,40.sp,color: Color(AppColors.white))
                Text(HomeScreenStrings.Promo.subtitle)
                    .foregroundColor(Color(AppColors.white))
                    .font(.system(size: 28.sp))


            }
            .padding()

            Spacer()

            VStack(alignment: .center) {
                HealthJourneyButtonFaceScanPromoView {
                    isNavigating = true
                }
                
                Button(action: {
                    showWebView = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: AppIconNames.Symbol.playCircleFill)
                            .foregroundColor(Color(AppColors.white))
                            .font(.title3)
                        Text(HomeScreenStrings.Promo.demoButtonTitle)
                            .font(.system(size: 25.sp, weight: .semibold))
                            .foregroundColor(Color(AppColors.white))
                            .underline()
                    }
                }
            }
            .padding()
        }
        .padding()
        .frame(height: 240.h)
        .background(Color(AppColors.accent))
        .clipShape(RoundedRectangle(cornerRadius: 24.r))
        .sheet(isPresented: $showWebView) {
            WebViewSheetView(url: URL(string: HomeScreenStrings.Promo.demoURL)!)
        }
        .onChange(of: showWebView) { _, isPresented in
            appState.setScreenSaverSuppressed(isPresented, reason: quickDemoSuppressionReason)
        }
        .onDisappear {
            appState.setScreenSaverSuppressed(false, reason: quickDemoSuppressionReason)
        }
    }
}
