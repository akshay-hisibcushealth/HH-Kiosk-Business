import SwiftUI

struct ScreenSaver: View {
    @State private var refreshTrigger = false
    @State private var showResponseReceivedToast = false
    let onStartFaceScan: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                screenBackground

                VStack(spacing: 0) {
                    ResultToolbar(isTransparent: true)

                    titleBlock
                        .padding(.top, 40.h)

                    Image(AppIconNames.Asset.screenSaverAvatar)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 780.w,height: 820.h)
                        .padding(.top, 48.w)
                        .padding(.horizontal, 12.w)


                    ScreenSaverFaceScanButton(action: onStartFaceScan)
                        .padding(.top, 54.h)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onReceive(NotificationCenter.default.publisher(for: .screenDidChangeBounds)) { _ in
                refreshTrigger.toggle()
            }
            .overlay(alignment: .top) {
                if showResponseReceivedToast {
                    ResponseReceivedToast()
                        .padding(.top, 214.h)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(2)
                }
            }
            .onAppear {
                presentResponseReceivedToastIfNeeded()
            }
        }
    }

    private var screenBackground: some View {
        Image(AppIconNames.Asset.screensaverBackground)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }


    private var titleBlock: some View {
        VStack(spacing: 18.h) {
            buildSemiBoldText(
                ScreenSaverStrings.title,
                42.sp,
                color: Color(AppColors.white)
            )
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.72)

            Text(ScreenSaverStrings.subtitle)
                .font(.system(size: 34.sp, weight: .regular))
                .foregroundColor(Color(AppColors.white).opacity(0.84))
                .multilineTextAlignment(.center)
                .lineSpacing(8.h)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
        }
        .padding(.horizontal, 70.w)
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
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 34.w) {
                assetSVG(AppIconNames.SvgAsset.smile, tintColor: Color(AppColors.white))
                    .scaledToFit()
                    .frame(width: 52.w, height: 52.h)

                Text(ScreenSaverStrings.actionButton)
                    .font(.system(size: 42.sp, weight: .bold))
                    .foregroundColor(Color(AppColors.white))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Image(systemName: AppIconNames.Symbol.arrowRight)
                    .font(.system(size: 34.sp, weight: .regular))
                    .foregroundColor(Color(AppColors.white))
                    .frame(width: 88.w, height: 88.h)
                    .background(Color(AppColors.white).opacity(0.20))
                    .clipShape(Circle())
            }
            .padding(.leading, 70.w)
            .padding(.trailing, 32.w)
            .frame(width: 600.w, height: 130.h)
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

private struct ResponseReceivedToast: View {
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
