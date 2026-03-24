import SwiftUI

struct FaceScanPromoView: View {
    @Binding var isNavigating: Bool
    @State private var showWebView = false

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(HomeScreenStrings.Promo.title)
                    .foregroundColor(Color(AppColors.white))
                    .font(.system(size: 32.sp, weight: .semibold))
                buildSemiBoldText(HomeScreenStrings.Promo.subtitle,36.sp,color: Color(AppColors.white))


            }
            .padding()

            Spacer()

            VStack(alignment: .center) {
                Button(action: {
                    isNavigating = true
                }) {
                    Image(AppIconNames.Asset.scanButton)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280.w, height: 80.h)
                        .padding(.top, 16.h)
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
        .background(Color(AppColors.primaryActionOrange))
        .clipShape(RoundedRectangle(cornerRadius: 24.r))
        .sheet(isPresented: $showWebView) {
            WebViewSheetView(url: URL(string: HomeScreenStrings.Promo.demoURL)!)
        }
        
    }
}
