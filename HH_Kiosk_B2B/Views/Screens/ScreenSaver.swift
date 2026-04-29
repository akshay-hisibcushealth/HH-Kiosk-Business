import SwiftUI

struct ScreenSaver: View {
    @StateObject private var viewModel = ScreenSaverViewModel()
    @State private var refreshTrigger = false

    var body: some View {
        ZStack {
            // Background
            Rectangle()
                   .fill(Color(AppColors.primary))
                   .ignoresSafeArea()
            Image(AppIconNames.Asset.screensaverBackground)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView(ScreenSaverStrings.loading)
                    .foregroundColor(Color(AppColors.white))
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
                        buildSemiBoldText(ScreenSaverStrings.title,40.sp,color: Color(AppColors.white))
                        
                        Text(ScreenSaverStrings.subtitle)
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
                                    .scaledToFit()
                            }
                            .padding(.trailing, 12.w)
                            .padding(.bottom, 12.w)
                            buildBoldText(ScreenSaverStrings.qrPrompt,30.sp,color: Color(AppColors.white))
                                .padding(.top, 12.h)
                            
                        }
                    }
                    
                    Spacer(minLength: 60.h)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onReceive(NotificationCenter.default.publisher(for: .screenDidChangeBounds)) { _ in
                           refreshTrigger.toggle()
                       }
            }
        }
    }
}
