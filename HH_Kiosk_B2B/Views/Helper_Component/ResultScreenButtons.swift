import SwiftUI
import AnuraCore

struct ResultScreenButtons: View {
    let result: [String: MeasurementResults.SignalResult]
    let onDownloadPDF: () -> Void
    let onPrint: () -> Void

    var body: some View {
        VStack(spacing: 16.h) {
            HStack(alignment: .top, spacing: 20.w) {
                HStack(spacing: 16.w) {
                    footerButton(
                        title: ResultScreenStrings.Actions.print.uppercased(),
                        image: Image(systemName: AppIconNames.Symbol.printerFill),
                        action: {
                            onPrint()
                        }
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: {
                    navigateToHome()
                }) {
                    Text(ResultScreenStrings.Actions.endSession.uppercased())
                        .font(.system(size: 20.sp, weight: .semibold))
                        .foregroundColor(Color(AppColors.primaryActionOrange))
                        .frame(width: 230.w)
                        .frame(minHeight: 72.h)
                        .background(Color(AppColors.resultAlertBackground).opacity(0.45))
                    .clipShape(RoundedRectangle(cornerRadius: 12.r, style: .continuous))
                }
            }
        }
        .padding(.top, 24.h)
        .padding(.horizontal, 30.w)
        .padding(.bottom, 18.h)
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
}

func navigateToHome(animated: Bool = true) {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else { return }

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
