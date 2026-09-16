import SwiftUI
import AnuraCore

struct ResultScreenButtons: View {
    let result: [String: MeasurementResults.SignalResult]
    let onDownloadPDF: () -> Void
    let onPrint: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 20.w) {
                footerPrimaryButton(
                    title: ResultScreenStrings.Actions.viewNextSteps,
                    action: {
                        navigateToPostSessionFlow()
                    }
                )
            }
            .padding(.top, 26.h)
            .padding(.horizontal, 30.w)
            .padding(.bottom, 12.h)
        }
        .frame(maxWidth: .infinity)
        .background(Color(AppColors.white).ignoresSafeArea(edges: .bottom))
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
            .frame(maxWidth: .infinity)
            .frame(minHeight: 72.h)
            .background(Color(AppColors.ctaGreen))
            .clipShape(RoundedRectangle(cornerRadius: 12.r, style: .continuous))
        }
        .frame(maxWidth: .infinity)
    }
}

@MainActor
func navigateToHome(animated: Bool = true, showResponseToast: Bool = false) {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else { return }

    ScanSessionStorage.clearMeasurementID()
    LocalUserStorage.clearUser()
    LocalUserStorage.clearClientID()
    PDFGenerator.removeAllTemporaryPHIFiles()

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
