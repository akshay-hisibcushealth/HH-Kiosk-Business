import SwiftUI

struct ScreenSaver: View {
    @EnvironmentObject private var appState: AppState
    @State private var refreshTrigger = false
    @State private var showResponseReceivedToast = false
    let onStartFaceScan: () -> Void

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
            Rectangle()
                .fill(Color(AppColors.primary))
                .ignoresSafeArea()

            Image(AppIconNames.Asset.screensaverBackground)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Toolbar()
                    .padding(.horizontal, 48.w)
                    .padding(.top, 75.h)
                    .frame(maxWidth: .infinity, alignment: .top)
                    
                    Spacer(minLength: 40.h)
                    
                    // Title text
                    VStack(spacing: 18.h) {
                        buildSemiBoldText(welcomeText, 42.sp, color: Color(AppColors.white))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)
                        
                        Text(subtitle)
                            .foregroundColor(Color(AppColors.white).opacity(0.84))
                            .font(.system(size: 34.sp, weight: .regular))
                            .multilineTextAlignment(.center)
                            .lineSpacing(8.h)
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)
                    }
                    .padding(.horizontal, 70.w)

                    Image(AppIconNames.Asset.screenSaverAvatar)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 630.w, height: 670.h)
                        .padding(.top, 48.h)
                        .padding(.horizontal, 12.w)
                    
                    ScreenSaverFaceScanButton(text: actionButtonText, action: onStartFaceScan)
                        .padding(.top, 54.h)
                    
                    Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onReceive(NotificationCenter.default.publisher(for: .screenDidChangeBounds)) { _ in
                refreshTrigger.toggle()
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

private struct ScreenSaverFaceScanButton: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 34.w) {
                assetSVG(AppIconNames.SvgAsset.smile, tintColor: Color(AppColors.white))
                    .scaledToFit()
                    .frame(width: 52.w, height: 52.h)

                Text(text)
                    .font(.system(size: 42.sp, weight: .bold))
                    .foregroundColor(Color(AppColors.white))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .layoutPriority(1)

                Image(systemName: AppIconNames.Symbol.arrowRight)
                    .font(.system(size: 34.sp, weight: .regular))
                    .foregroundColor(Color(AppColors.white))
                    .frame(width: 88.w, height: 88.h)
                    .background(Color(AppColors.white).opacity(0.20))
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
            .shadow(
                color: Color(red: 1.0, green: 0.45, blue: 0.0).opacity(0.34),
                radius: 28,
                x: 0,
                y: 22
            )
        }
        .buttonStyle(.plain)
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
