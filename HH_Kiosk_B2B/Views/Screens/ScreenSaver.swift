import SwiftUI

struct ScreenSaver: View {
    @StateObject private var viewModel = ScreenSaverViewModel()
    
    var body: some View {
        ZStack {
            // Background
            Image("screensaverbg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .foregroundColor(.white)
                    .font(.system(size: 28.sp))
            } else {
                VStack(spacing: 0) {
                    // Toolbar (Logo + Time)
                    Toolbar()
                        .padding(.horizontal, 48.w)
                        .padding(.top, 75.h)
                        .frame(maxWidth: .infinity, alignment: .top)
                    
                    Spacer(minLength: 100.h)
                    
                    // Title text
                    VStack(spacing: 24.h) {
                        buildSemiBoldText("Welcome to the Hibiscus Wellness Kiosk!",40.sp,color: Color(AppColors.white))
                      
                        
                        Text("Take a few minutes to check in on your health.")
                            .foregroundColor(Color(AppColors.white))
                            .font(.system(size: 34.sp, weight: .regular))
                            .multilineTextAlignment(.center)
                            .padding(.top, -15.h)
                    }
                    .padding(.horizontal, 60.w)
                    
                    Spacer(minLength: 80.h)
                    
                    // Dynamic carousel
                    if !viewModel.images.isEmpty {
                        ImageCarouselView(imageURLs: viewModel.images)
                    }
                    
                    // Button
                    HealthJourneyButton()
                        .padding(.vertical, 100.h)
                    
                    // Dynamic QR code section
                    if let qrURL = viewModel.qrImage, let url = URL(string: qrURL) {
                        VStack(spacing: 24.h) {
                            CachedAsyncImage(
                                url: url,
                                width: 200.w,
                                height: 200.h,
                                cornerRadius: 24.r
                            ) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            }
                            .padding(.trailing, 12.w)
                            .padding(.bottom, 12.w)
                            buildBoldText("Scan to try it on your smartphone!",30.sp,color: Color(AppColors.white))
                                .padding(.top, 12.h)
                            
                        }
                    }
                    
                    Spacer(minLength: 60.h)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
