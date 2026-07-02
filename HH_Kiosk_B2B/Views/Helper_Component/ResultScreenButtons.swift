import SwiftUI
import AnuraCore

struct ResultScreenButtons: View {
    let result: [String: MeasurementResults.SignalResult]
    let onDownloadPDF: () -> Void
    let onPrint: () -> Void

    @State private var showEmailPopUp = false
    @State private var isEmailSent = false
    var body: some View {
        HStack(alignment: .center, spacing: 20.w) {
                HStack(spacing: 16.w) {
                    footerButton(
                        title: ResultScreenStrings.Actions.emailResults,
                        image: Image(AppIconNames.Asset.email),
                        action: {
                            isEmailSent = false
                            showEmailPopUp = true
                        }
                    )

                    footerButton(
                        title: ResultScreenStrings.Actions.print,
                        image: Image(systemName: AppIconNames.Symbol.printerFill),
                        action: {
                            onPrint()
                        }
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                footerPrimaryButton(
                    title: ResultScreenStrings.Actions.viewNextSteps,
                    action: {
                        navigateToPostSessionFlow()
                    }
                )
            }
            .fullScreenCover(isPresented: $showEmailPopUp, onDismiss: {
                isEmailSent = false
            }) {
                ResultPromptOverlay(layout: isEmailSent ? .emailSuccess : .emailEntry) {
                    EmailResultPopup(
                        results: result,
                        isEmailSent: $isEmailSent
                    )
                }
                .presentationBackground(Color.clear)
            }
        .padding(.top, 26.h)
        .padding(.horizontal, 30.w)
        .padding(.bottom, 26.h)
        .background(
            Color(AppColors.white)
                .shadow(color: Color(AppColors.black).opacity(0.18), radius: 14, x: 0, y: -4)
        )
        .overlay(alignment: .top) {
            LinearGradient(
                colors: [
                    Color.clear,
                    Color(AppColors.black).opacity(0.08),
                    Color(AppColors.black).opacity(0.18)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 28.h)
            .offset(y: -28.h)
            .allowsHitTesting(false)
        }
    }

    private func footerButton(title: String, image: Image, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16.w) {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24.w, height: 24.h)
                    .foregroundColor(Color(AppColors.black))

                Text(title)
                    .font(.system(size: 20.sp, weight: .semibold))
                    .foregroundColor(Color(AppColors.black))
            }
            .frame(width: 270.w)
            .frame(minHeight: 72.h)
            .background(Color(AppColors.white))
            .overlay(
                RoundedRectangle(cornerRadius: 12.r, style: .continuous)
                    .stroke(Color(AppColors.black).opacity(0.7), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12.r, style: .continuous))
        }
    }

    private func footerPrimaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16.w) {
                Text(title)
                    .font(.system(size: 20.sp, weight: .semibold))
                    .foregroundColor(Color(AppColors.black))

                Image(systemName: AppIconNames.Symbol.arrowRight)
                    .font(.system(size: 24.sp, weight: .semibold))
                    .foregroundColor(Color(AppColors.black))
            }
            .frame(width: 550.w)
            .frame(minHeight: 72.h)
            .background(Color(AppColors.ctaGreen))
            .clipShape(RoundedRectangle(cornerRadius: 12.r, style: .continuous))
        }
    }
}

private enum ResultPromptOverlayLayout {
    case emailEntry
    case emailSuccess

    func width(in proxy: GeometryProxy) -> CGFloat {
        min(proxy.size.width * 0.79, 1088.w)
    }

    func height(in proxy: GeometryProxy) -> CGFloat {
        min(proxy.size.height * 0.53, 1040.h)
    }
}

private struct ResultPromptOverlay<Content: View>: View {
    let layout: ResultPromptOverlayLayout
    let content: () -> Content

    init(layout: ResultPromptOverlayLayout = .emailEntry, @ViewBuilder content: @escaping () -> Content) {
        self.layout = layout
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(AppColors.black)
                    .opacity(0.28)
                    .ignoresSafeArea()

                content()
                    .frame(
                        width: layout.width(in: proxy),
                        height: layout.height(in: proxy)
                    )
                    .background(Color(AppColors.white))
                    .clipShape(RoundedRectangle(cornerRadius: 54.r, style: .continuous))
                    .shadow(color: Color(AppColors.black).opacity(0.16), radius: 28, x: 0, y: 22)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

func navigateToHome(animated: Bool = true, showResponseToast: Bool = false) {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else { return }

    ScanSessionStorage.clearMeasurementID()

    if showResponseToast {
        UserDefaults.standard.set(true, forKey: AppStorageKeys.responseReceivedToastPending)
    }

    let rootView = RootView()
    let hostingController = UIHostingController(rootView: rootView)

    if animated {
        // Add a smooth crossfade transition
        let transition = CATransition()
        transition.type = .fade
        transition.duration = 0.4 // ⏱ adjust smoothness here (0.3–0.6 works best)
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        window.layer.add(transition, forKey: kCATransition)
    }

    window.rootViewController = hostingController
    window.makeKeyAndVisible()
}

private weak var presentedPostSessionFlowController: UIViewController?

func navigateToPostSessionFlow(animated: Bool = true, emailWasSent: Bool = false) {
    if presentedPostSessionFlowController != nil {
        return
    }

    guard let topViewController = UIApplication.topViewController() else { return }

    let hostingController = UIHostingController(rootView: PostSessionFlowScreen(emailWasSent: emailWasSent))
    hostingController.modalPresentationStyle = .fullScreen
    hostingController.modalTransitionStyle = .crossDissolve
    presentedPostSessionFlowController = hostingController

    topViewController.present(hostingController, animated: animated)
}

func navigateBackFromPostSessionFlow(animated: Bool = true) {
    guard let postSessionController = presentedPostSessionFlowController ?? UIApplication.topViewController() else {
        return
    }

    postSessionController.dismiss(animated: animated) {
        presentedPostSessionFlowController = nil
    }
}
