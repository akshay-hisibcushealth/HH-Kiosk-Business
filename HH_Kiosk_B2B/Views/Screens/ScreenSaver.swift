import SwiftUI

struct ScreenSaver: View {
    @EnvironmentObject private var appState: AppState
    @State private var refreshTrigger = false
    @State private var showResponseReceivedToast = false
    let onStartFaceScan: () -> Void

    private enum ScreenSaverAssetTitle {
        static let qrImage = "qr"
    }

    private var carouselImages: [String] {
        guard let data = appState.screenSaverData else { return [] }

        return data.carouselImages
            .filter { !$0.title.lowercased().contains(ScreenSaverAssetTitle.qrImage) }
            .sorted { lhs, rhs in
                if lhs.order == rhs.order {
                    return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
                }

                return lhs.order < rhs.order
            }
            .map(\.imageURL)
    }

    private var qrImageURL: String? {
        appState.screenSaverData?.carouselImages.first(where: {
            $0.title.lowercased().contains(ScreenSaverAssetTitle.qrImage)
        })?.imageURL
    }

    private var welcomeText: String {
        appState.screenSaverData?.welcomeText ?? ScreenSaverStrings.title
    }

    private var subtitle: String {
        appState.screenSaverData?.subtitle ?? ScreenSaverStrings.subtitle
    }

    private var actionButtonText: String {
        appState.screenSaverData?.actionButtonText ?? ScreenSaverStrings.actionButton
    }

    
    var body: some View {
        ZStack {
            // Background
            //here we need to add a ractangle background that cover whole screen color will be AppColors.primary
            Rectangle()
                   .fill(Color(AppColors.primary))
                   .ignoresSafeArea()
            Image(AppIconNames.Asset.screensaverBackground)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            if appState.isScreenSaverDataLoading && appState.screenSaverData == nil {
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
                        buildSemiBoldText(welcomeText,40.sp,color: Color(AppColors.white))
                        
                        Text(subtitle)
                            .foregroundColor(Color(AppColors.white))
                            .font(.system(size: 34.sp, weight: .regular))
                            .multilineTextAlignment(.center)
                            .padding(.top, -15.h)
                    }
                    .padding(.horizontal, 60.w)
                    
                    Spacer(minLength: 80.h)
                    
                    // Dynamic carousel
                    if !carouselImages.isEmpty {
                        ImageCarouselView(imageURLs: carouselImages)
                    }
                    
                    // Button
                    HealthJourneyButton(text: actionButtonText, action: onStartFaceScan)
                        .padding(.vertical, 100.h)
                    
                    // Dynamic QR code section
                    if let qrURL = qrImageURL, let url = URL(string: qrURL) {
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
        .task {
            if appState.screenSaverData == nil {
                await appState.warmScreenSaverData()
            }
        }
        .overlay(alignment: .top) {
            if showResponseReceivedToast {
                ScreenSaverResponseReceivedToast()
                    .padding(.top, 214.h)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(2)
            }
        }
        .onAppear {
            presentResponseReceivedToastIfNeeded()
        }
    }

    private func presentResponseReceivedToastIfNeeded() {
        guard UserDefaults.standard.bool(forKey: AppStorageKeys.responseReceivedToastPending) else { return }
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.responseReceivedToastPending)

        withAnimation(.easeOut(duration: 0.25)) {
            showResponseReceivedToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeIn(duration: 0.2)) {
                showResponseReceivedToast = false
            }
        }
    }
}

private struct ScreenSaverResponseReceivedToast: View {
    var body: some View {
        HStack(spacing: 18.w) {
            ZStack {
                Circle()
                    .fill(Color(AppColors.white))
                    .frame(width: 44.w, height: 44.w)

                Image(systemName: "checkmark")
                    .font(.system(size: 26.sp, weight: .bold))
                    .foregroundColor(Color(red: 0.39, green: 0.76, blue: 0.0))
            }

            Text(HomeScreenStrings.responseReceivedToast)
                .font(.system(size: 28.sp, weight: .bold))
                .foregroundColor(Color(AppColors.white))

            Spacer()
        }
        .padding(.horizontal, 34.w)
        .frame(width: 980.w, height: 88.h)
        .background(Color(red: 0.39, green: 0.76, blue: 0.0))
        .clipShape(RoundedRectangle(cornerRadius: 8.r, style: .continuous))
    }
}
