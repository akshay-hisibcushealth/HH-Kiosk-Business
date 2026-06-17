import SwiftUI

private enum PostSessionStep {
    case nextSteps
    case nps
}

private struct PostSessionNextStepOption: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String

    var response: KioskNextStepResponse {
        KioskNextStepResponse(id: id, title: title, description: description)
    }
}

struct PostSessionFlowScreen: View {
    let emailWasSent: Bool

    @State private var step: PostSessionStep = .nextSteps
    @State private var selectedOptionIDs: Set<String> = []
    @State private var selectedScore: Int?
    @State private var isSubmitting = false
    @State private var showSubmitError = false

    private let submissionService: KioskSubmissionServiceProtocol = KioskSubmissionService()

    init(emailWasSent: Bool = false) {
        self.emailWasSent = emailWasSent
    }

    private var options: [PostSessionNextStepOption] {
        [
            PostSessionNextStepOption(
                id: "annual_physical",
                title: ResultScreenStrings.PostSession.NextSteps.annualPhysical,
                description: ResultScreenStrings.PostSession.NextSteps.annualPhysical
            ),
            PostSessionNextStepOption(
                id: "biometric_screening",
                title: ResultScreenStrings.PostSession.NextSteps.biometricScreening,
                description: ResultScreenStrings.PostSession.NextSteps.biometricScreening
            ),
            PostSessionNextStepOption(
                id: "nutrition_counseling",
                title: ResultScreenStrings.PostSession.NextSteps.nutritionCounseling,
                description: ResultScreenStrings.EmailPopup.NextSteps.dietitianBody
            ),
            PostSessionNextStepOption(
                id: "ongoing_monitoring",
                title: ResultScreenStrings.PostSession.NextSteps.ongoingMonitoring,
                description: ResultScreenStrings.EmailPopup.NextSteps.monitoringBodyPrefix
                    + ResultScreenStrings.EmailPopup.NextSteps.monitoringCode
                    + ResultScreenStrings.EmailPopup.NextSteps.monitoringBodySuffix
            )
        ]
    }

    private var selectedResponses: [KioskNextStepResponse] {
        options
            .filter { selectedOptionIDs.contains($0.id) }
            .map(\.response)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            Group {
                switch step {
                case .nextSteps:
                    nextStepsContent
                case .nps:
                    npsContent
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            footer
        }
        .background(Color(AppColors.systemBackground))
    }

    private var header: some View {
        VStack(spacing: 0) {
            postSessionToolbar
                .frame(height: 92.h)

            HStack(spacing: 0) {
                progressItem(number: "1", title: "About You", isActive: false)
                progressItem(number: "2", title: "Face Scan", isActive: false)
                progressItem(number: "3", title: "Your Report", isActive: false)
                progressItem(number: "4", title: "Next Steps", isActive: true)
            }
            .frame(height: 38.h)
            .background(Color(AppColors.white))
            .overlay(alignment: .bottomTrailing) {
                Rectangle()
                    .fill(Color(AppColors.ctaGreen))
                    .frame(width: UIScreen.main.bounds.width * 0.25, height: 3.h)
            }
        }
    }

    private var postSessionToolbar: some View {
        HStack {
            Image(AppIconNames.Asset.logo)
                .resizable()
                .scaledToFit()
                .frame(width: 154.w, height: 58.h)

            Spacer()

            Text(SharedViewStrings.Toolbar.companyLogoPlaceholder)
                .font(.system(size: 15.sp, weight: .semibold))
                .foregroundColor(Color(AppColors.white))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(width: 215.w, height: 54.h)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color(AppColors.white), lineWidth: 3.w)
                )
        }
        .padding(.horizontal, 30.w)
        .background(Color(AppColors.primary))
    }

    private func progressItem(number: String, title: String, isActive: Bool) -> some View {
        HStack(spacing: 8.w) {
            Text(number)
                .font(.system(size: 10.sp, weight: .bold))
                .foregroundColor(isActive ? Color(AppColors.white) : Color(AppColors.gray).opacity(0.45))
                .frame(width: 16.w, height: 16.w)
                .background(isActive ? Color(AppColors.primary) : Color(AppColors.gray).opacity(0.12))
                .clipShape(Circle())

            Text(title)
                .font(.system(size: 12.sp, weight: isActive ? .bold : .semibold))
                .foregroundColor(isActive ? Color(AppColors.black) : Color(AppColors.gray).opacity(0.48))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private var nextStepsContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8.h) {
                buildSemiBoldText(ResultScreenStrings.PostSession.nextStepsHeading, 25.sp, color: Color(AppColors.black))
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Text(ResultScreenStrings.PostSession.nextStepsSubtitle)
                    .font(.system(size: 14.sp, weight: .regular))
                    .foregroundColor(Color(AppColors.black))
            }
            .padding(.top, 44.h)
            .padding(.horizontal, 58.w)

            VStack(spacing: 12.h) {
                ForEach(options) { option in
                    optionRow(option)
                }
            }
            .padding(.top, 40.h)
            .padding(.horizontal, 58.w)

            Spacer()
        }
    }

    private func optionRow(_ option: PostSessionNextStepOption) -> some View {
        let isSelected = selectedOptionIDs.contains(option.id)

        return Button {
            toggleOption(option)
        } label: {
            HStack(spacing: 18.w) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4.r, style: .continuous)
                        .fill(isSelected ? Color(AppColors.ctaGreen) : Color(AppColors.white))
                        .frame(width: 24.w, height: 24.w)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4.r, style: .continuous)
                                .stroke(isSelected ? Color(AppColors.ctaGreen) : Color(AppColors.gray).opacity(0.45), lineWidth: 2.w)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13.sp, weight: .black))
                            .foregroundColor(Color(AppColors.black))
                    }
                }

                Text(option.title)
                    .font(.system(size: 14.sp, weight: .semibold))
                    .foregroundColor(Color(AppColors.black))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20.w)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 64.h)
            .background(isSelected ? Color(AppColors.ctaGreen).opacity(0.12) : Color(AppColors.white))
            .overlay(
                RoundedRectangle(cornerRadius: 6.r, style: .continuous)
                    .stroke(isSelected ? Color(AppColors.ctaGreen) : Color(AppColors.gray).opacity(0.45), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 6.r, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var npsContent: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 44.h)

            successMark
                .padding(.bottom, 20.h)

            buildSemiBoldText(ResultScreenStrings.PostSession.allDoneTitle, 24.sp, color: Color(AppColors.black))
                .padding(.bottom, 10.h)

            Text(emailWasSent ? ResultScreenStrings.PostSession.emailSentBody : ResultScreenStrings.PostSession.completionBody)
                .font(.system(size: 14.sp, weight: .regular))
                .foregroundColor(Color(AppColors.black))
                .multilineTextAlignment(.center)
                .padding(.bottom, 7.h)

            Text(ResultScreenStrings.PostSession.completionSubtitle)
                .font(.system(size: 14.sp, weight: .regular))
                .foregroundColor(Color(AppColors.black))

            Spacer(minLength: 52.h)

            npsCard
                .padding(.horizontal, 62.w)

            if showSubmitError {
                Text(ResultScreenStrings.PostSession.submitFailure)
                    .font(.system(size: 16.sp, weight: .semibold))
                    .foregroundColor(Color(AppColors.error))
                    .padding(.top, 18.h)
            }

            Spacer(minLength: 42.h)
        }
    }

    private var successMark: some View {
        ZStack {
            Circle()
                .fill(Color(AppColors.ctaGreen).opacity(0.32))
                .frame(width: 84.w, height: 84.w)

            Circle()
                .fill(Color(red: 0.47, green: 0.78, blue: 0.0))
                .frame(width: 56.w, height: 56.w)

            Image(systemName: "checkmark")
                .font(.system(size: 28.sp, weight: .black))
                .foregroundColor(Color(AppColors.black))
        }
    }

    private var npsCard: some View {
        VStack(spacing: 10.h) {
            Text(ResultScreenStrings.PostSession.npsEyebrow)
                .font(.system(size: 10.sp, weight: .black))
                .foregroundColor(Color(AppColors.primary))

            buildSemiBoldText(ResultScreenStrings.PostSession.npsQuestion, 21.sp, color: Color(AppColors.black))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            HStack(spacing: 8.w) {
                ForEach(1...10, id: \.self) { score in
                    scoreButton(score)
                }
            }
            .padding(.top, 4.h)

            HStack {
                Text(ResultScreenStrings.PostSession.notLikely)
                Spacer()
                Text(ResultScreenStrings.PostSession.extremelyLikely)
            }
            .font(.system(size: 10.sp, weight: .regular))
            .foregroundColor(Color(AppColors.black))
            .padding(.horizontal, 8.w)
        }
        .padding(.horizontal, 14.w)
        .padding(.vertical, 24.h)
        .frame(maxWidth: .infinity)
        .background(Color(AppColors.white))
        .overlay(
            RoundedRectangle(cornerRadius: 6.r, style: .continuous)
                .stroke(Color(AppColors.formBorder), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 6.r, style: .continuous))
    }

    private func scoreButton(_ score: Int) -> some View {
        Button {
            selectedScore = score
        } label: {
            Text("\(score)")
                .font(.system(size: 11.sp, weight: .bold))
                .foregroundColor(Color(AppColors.primary))
                .frame(maxWidth: .infinity)
                .frame(height: 38.h)
                .background(selectedScore == score ? Color(AppColors.ctaGreen) : Color(AppColors.formBorder).opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 5.r, style: .continuous)
                        .stroke(selectedScore == score ? Color(red: 0.35, green: 0.63, blue: 0.0) : Color(AppColors.formBorder), lineWidth: selectedScore == score ? 3.w : 1.w)
                )
                .clipShape(RoundedRectangle(cornerRadius: 5.r, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var footer: some View {
        HStack(spacing: 24.w) {
            if step == .nps {
                Button(action: { submitAndReturnHome(npsScore: nil) }) {
                    footerText(ResultScreenStrings.PostSession.skip, width: 178.w, foreground: Color(AppColors.black), background: Color(AppColors.white), bordered: true)
                }
                .disabled(isSubmitting)
            } else {
                Spacer()
                    .frame(width: 178.w)
            }

            Button(action: primaryAction) {
                ZStack {
                    footerText(
                        step == .nextSteps ? ResultScreenStrings.PostSession.continueTitle : ResultScreenStrings.PostSession.submitAndReturnHome,
                        width: step == .nextSteps ? 380.w : 560.w,
                        foreground: Color(AppColors.black),
                        background: Color(AppColors.ctaGreen),
                        bordered: false
                    )
                    .opacity(isSubmitting ? 0 : 1)

                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(AppColors.black)))
                    }
                }
            }
            .disabled(isSubmitting || (step == .nps && selectedScore == nil))
            .opacity((step == .nextSteps || selectedScore != nil || isSubmitting) ? 1 : 0.55)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 28.w)
        .padding(.vertical, 14.h)
        .background(
            Color(AppColors.white)
                .shadow(color: Color(AppColors.black).opacity(0.18), radius: 14, x: 0, y: -4)
        )
    }

    private func footerText(_ text: String, width: CGFloat, foreground: Color, background: Color, bordered: Bool) -> some View {
        Text(text)
            .font(.system(size: 18.sp, weight: .bold))
            .foregroundColor(foreground)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .frame(width: width)
            .frame(height: 54.h)
            .background(background)
            .overlay(
                RoundedRectangle(cornerRadius: 6.r, style: .continuous)
                    .stroke(bordered ? Color(AppColors.black).opacity(0.7) : Color.clear, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 6.r, style: .continuous))
    }

    private func toggleOption(_ option: PostSessionNextStepOption) {
        if selectedOptionIDs.contains(option.id) {
            selectedOptionIDs.remove(option.id)
        } else {
            selectedOptionIDs.insert(option.id)
        }
    }

    private func primaryAction() {
        switch step {
        case .nextSteps:
            withAnimation(.easeInOut(duration: 0.2)) {
                step = .nps
            }
        case .nps:
            submitAndReturnHome(npsScore: selectedScore)
        }
    }

    private func submitAndReturnHome(npsScore: Int?) {
        guard !isSubmitting else { return }

        Task {
            await MainActor.run {
                isSubmitting = true
                showSubmitError = false
            }

            do {
                if let email = LocalUserStorage.loadEmail(),
                   !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    _ = try await submissionService.sendUserResponse(
                        email: email,
                        nextSteps: selectedResponses,
                        npsScore: npsScore
                    )
                }

                await MainActor.run {
                    navigateToHome(showResponseToast: !selectedResponses.isEmpty || npsScore != nil)
                }
            } catch {
                print("Kiosk post-session response error:", error.localizedDescription)
                await MainActor.run {
                    isSubmitting = false
                    showSubmitError = true
                }
            }
        }
    }
}
