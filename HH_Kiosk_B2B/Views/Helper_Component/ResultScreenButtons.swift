import SwiftUI
import AnuraCore

struct ResultScreenButtons: View {
    let result: [String: MeasurementResults.SignalResult]
    let onDownloadPDF: () -> Void
    let onPrint: () -> Void

    private let submissionService: KioskSubmissionServiceProtocol = KioskSubmissionService()
    @State private var showEmailPopUp = false
    @State private var showEndSessionPrompt = false
    var body: some View {
        VStack(spacing: 16.h) {
            HStack(alignment: .top, spacing: 20.w) {
                HStack(spacing: 16.w) {
                    footerButton(
                        title: ResultScreenStrings.Actions.emailMyResults.uppercased(),
                        image: Image(AppIconNames.Asset.email),
                        action: {
                            showEmailPopUp = true
                        }
                    )

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
                    showEndSessionPrompt = true
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

            HStack(spacing: 8.w) {
                Image(AppIconNames.Asset.secureEmail)
                    .resizable()
                    .frame(width: 24.w, height: 24.h)

                Text(ResultScreenStrings.Actions.secureAndPrivate)
                    .foregroundColor(Color(AppColors.blue))
                    .font(.system(size: 18.sp, weight: .semibold))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .fullScreenCover(isPresented: $showEmailPopUp) {
                ResultPromptOverlay {
                    EmailResultPopup(results: result)
                }
                .presentationBackground(Color.clear)
            }
            .fullScreenCover(isPresented: $showEndSessionPrompt) {
                ResultPromptOverlay {
                    NextStepsPromptView(
                        mode: .endSession,
                        closeAction: {
                            showEndSessionPrompt = false
                            navigateToHome()
                        },
                        confirmAction: { title, description in
                            await submitUserResponse(title: title, description: description)
                        }
                    )
                }
                .presentationBackground(Color.clear)
            }
        }
        .padding(.top, 24.h)
        .padding(.horizontal, 30.w)
        .padding(.bottom, 18.h)
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

    private func submitUserResponse(title: String, description: String) async -> Bool {
        guard let email = LocalUserStorage.loadEmail(),
              !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        do {
            _ = try await submissionService.sendUserResponse(
                email: email,
                title: title,
                description: description
            )
            await MainActor.run {
                showEndSessionPrompt = false
                navigateToHome(showResponseToast: true)
            }
            return true
        } catch {
            print("❌ Kiosk user response error:", error.localizedDescription)
            return false
        }
    }
}

private struct ResultPromptOverlay<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
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
                        width: min(proxy.size.width * 0.82, 960.w),
                        height: min(proxy.size.height * 0.76, 1280.h)
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
