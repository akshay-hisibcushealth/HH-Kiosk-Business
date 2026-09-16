import SwiftUI

struct ScreenSaver: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var orientation: OrientationManager
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
        GeometryReader { geometry in
            Group {
                if orientation.isLandscape {
                    landscapeContent(size: geometry.size)
                } else {
                    portraitContent
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background {
                Color(AppColors.primary)
                    .overlay {
                        if orientation.isLandscape {
                            ScreenSaverCircuitBackground()
                        } else {
                            Image(AppIconNames.Asset.screensaverBackground)
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .clipped()
                    .ignoresSafeArea()
            }
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

    private var portraitContent: some View {
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

                    avatar
                        .padding(.top, 48.h)
                        .padding(.horizontal, 12.w)

                    ScreenSaverFaceScanButton(text: actionButtonText, action: onStartFaceScan)
                        .padding(.top, 54.h)

                    Spacer()
            }
    }

    private var avatar: some View {
        Image(AppIconNames.Asset.screenSaverAvatar)
            .resizable()
            .scaledToFit()
            .frame(width: 630.w, height: 670.h)
    }

    private func landscapeContent(size: CGSize) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Image(AppIconNames.Asset.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width * 0.15, height: size.height * 0.09)

                Spacer()

                Text(ScreenSaverStrings.landscapeCompanyLogo)
                    .font(.system(size: 24.sp, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .frame(width: size.width * 0.15, height: size.height * 0.085)
                    .overlay(Rectangle().stroke(.white, lineWidth: 4.w))
            }
            .padding(.horizontal, size.width * 0.05)
            .padding(.top, size.height * 0.035)

            HStack(spacing: size.width * 0.035) {
                Image(AppIconNames.Asset.screenSaverAvatar)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width * 0.38, height: size.height * 0.64)

                VStack(spacing: 0) {
                    buildSemiBoldText(ScreenSaverStrings.landscapeTitle, 42.sp, color: .white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    Text(ScreenSaverStrings.landscapeSubtitle)
                        .font(.system(size: 32.sp, weight: .regular))
                        .foregroundColor(Color(red: 0.76, green: 0.89, blue: 0.97))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, size.height * 0.055)

                    ScreenSaverFaceScanButton(text: ScreenSaverStrings.landscapeActionButton, action: onStartFaceScan)
                        .padding(.top, size.height * 0.10)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, size.width * 0.05)
            .padding(.top, size.height * 0.055)
            .frame(maxHeight: .infinity, alignment: .top)
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

/// Decorative circuit traces scale with the landscape screen, without affecting its layout.
private struct ScreenSaverCircuitBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color(red: 0.06, green: 0.12, blue: 0.32), Color(red: 0.11, green: 0.20, blue: 0.40)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Canvas { context, size in
                let routes: [[CGPoint]] = [
                    [.init(x: 0, y: 0.18), .init(x: 0.22, y: 0.18), .init(x: 0.34, y: 0)],
                    [.init(x: 0, y: 0.85), .init(x: 0.25, y: 0.85), .init(x: 0.43, y: 0.60), .init(x: 0.43, y: 0.42)],
                    [.init(x: 0.10, y: 1), .init(x: 0.35, y: 0.72), .init(x: 0.35, y: 0.60)],
                    [.init(x: 0.63, y: 0), .init(x: 0.63, y: 0.30), .init(x: 0.54, y: 0.42), .init(x: 0.54, y: 0.68)],
                    [.init(x: 0.69, y: 0), .init(x: 0.69, y: 0.36), .init(x: 0.79, y: 0.49), .init(x: 1, y: 0.49)],
                    [.init(x: 1, y: 0.19), .init(x: 0.82, y: 0.19), .init(x: 0.74, y: 0.31)],
                    [.init(x: 1, y: 0.73), .init(x: 0.86, y: 0.73), .init(x: 0.71, y: 0.90), .init(x: 0.71, y: 1)],
                    [.init(x: 0.43, y: 1), .init(x: 0.56, y: 0.84), .init(x: 0.80, y: 0.84)]
                ]
                for route in routes {
                    for offset in [CGFloat(0), 0.012, 0.024] {
                        var path = Path()
                        for (index, point) in route.enumerated() {
                            let position = CGPoint(x: (point.x + offset) * size.width, y: (point.y + offset) * size.height)
                            if index == 0 { path.move(to: position) } else { path.addLine(to: position) }
                        }
                        context.stroke(path, with: .color(.white.opacity(0.045)), lineWidth: 2)
                    }
                }
                for index in 0..<55 {
                    let x = CGFloat((index * 137 + 23) % 997) / 997 * size.width
                    let y = CGFloat((index * 239 + 61) % 991) / 991 * size.height
                    context.fill(Path(CGRect(x: x, y: y, width: 3, height: 3)), with: .color(.white.opacity(0.10)))
                }
            }
        }
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}
