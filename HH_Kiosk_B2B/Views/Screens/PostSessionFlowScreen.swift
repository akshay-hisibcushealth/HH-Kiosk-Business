import SwiftUI

private enum PostSessionStep {
    case nextSteps
    case nps
}

private enum PostSessionSubmissionAction {
    case npsSkip
    case npsSubmit
}

private struct PostSessionNextStepOption: Identifiable, Equatable {
    let id: Int
    let displayTitle: String
    let responseTitle: String
    let description: String

    var response: KioskNextStepResponse {
        KioskNextStepResponse(id: id, title: responseTitle, description: description)
    }
}

struct PostSessionFlowScreen: View {
    let emailWasSent: Bool

    @State private var step: PostSessionStep = .nextSteps
    @State private var selectedOptionIDs: Set<Int> = []
    @State private var selectedScore: Int?
    @State private var isSubmitting = false
    @State private var activeSubmissionAction: PostSessionSubmissionAction?
    @State private var showSubmitError = false

    private let submissionService: KioskSubmissionServiceProtocol = KioskSubmissionService()

    init(emailWasSent: Bool = false) {
        self.emailWasSent = emailWasSent
    }

    private var options: [PostSessionNextStepOption] {
        [
            PostSessionNextStepOption(
                id: 0,
                displayTitle: ResultScreenStrings.PostSession.NextSteps.annualPhysical,
                responseTitle: "Annual Physical",
                description: ResultScreenStrings.PostSession.NextSteps.annualPhysical
            ),
            PostSessionNextStepOption(
                id: 1,
                displayTitle: ResultScreenStrings.PostSession.NextSteps.biometricScreening,
                responseTitle: "Biometric Screening",
                description: ResultScreenStrings.PostSession.NextSteps.biometricScreening
            ),
            PostSessionNextStepOption(
                id: 2,
                displayTitle: ResultScreenStrings.PostSession.NextSteps.nutritionCounseling,
                responseTitle: "Nutrition Counseling",
                description: ResultScreenStrings.EmailPopup.NextSteps.dietitianBody
            ),
            PostSessionNextStepOption(
                id: 3,
                displayTitle: ResultScreenStrings.PostSession.NextSteps.ongoingMonitoring,
                responseTitle: "Ongoing Monitoring",
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
            ResultToolbar()

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
                buildSemiBoldText(ResultScreenStrings.PostSession.nextStepsHeading, 42.sp, color: Color(AppColors.black))
                    .lineLimit(2)

                Text(ResultScreenStrings.PostSession.nextStepsSubtitle)
                    .font(.system(size: 32.sp, weight: .regular))
                    .foregroundColor(Color(AppColors.black))
            }
            .padding(.top, 58.h)
            .padding(.horizontal, 58.w)

            VStack(spacing: 48.h) {
                ForEach(options) { option in
                    optionRow(option)
                        .disabled(isSubmitting)
                }
            }
            .padding(.top, 58.h)
            .padding(.horizontal, 58.w)

            Spacer()

            if showSubmitError {
                submitErrorText
                    .padding(.horizontal, 58.w)
                    .padding(.bottom, 20.h)
            }
        }
    }

    private func optionRow(_ option: PostSessionNextStepOption) -> some View {
        let isSelected = selectedOptionIDs.contains(option.id)

        return Button {
            toggleOption(option)
        } label: {
            HStack(spacing: 22.w) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4.r, style: .continuous)
                        .fill(isSelected ? Color(AppColors.ctaGreen) : Color(AppColors.white))
                        .frame(width: 30.w, height: 30.w)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4.r, style: .continuous)
                                .stroke(isSelected ? Color.clear : Color(AppColors.gray).opacity(0.45), lineWidth: 3.w)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 17.sp, weight: .black))
                            .foregroundColor(Color(AppColors.black))
                    }
                }

                Text(option.displayTitle)
                    .font(.system(size: 28.sp, weight: isSelected ? .bold : .regular))
                    .foregroundColor(Color(AppColors.black))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)

                Spacer(minLength: 0)
            }
            .padding(.vertical, 40.w)
            .padding(.horizontal, 28.w)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color(AppColors.ctaGreen).opacity(0.12) : Color(AppColors.white))
            .overlay(
                RoundedRectangle(cornerRadius: 6.r, style: .continuous)
                    .stroke(isSelected ? Color(AppColors.ctaGreen) : Color(AppColors.gray).opacity(0.45), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 6.r, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isSubmitting)
    }

    private var npsContent: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 86.h)

            successMark
                .padding(.bottom, 38.h)

            buildMediumText(ResultScreenStrings.PostSession.allDoneTitle, 36.sp, color: Color(AppColors.black))
                .padding(.bottom, 18.h)

            Text(ResultScreenStrings.PostSession.allDoneDescription)
                .font(.system(size: 26.sp, weight: .light))
                .foregroundColor(Color(AppColors.black))
                .multilineTextAlignment(.center)
                .padding(.bottom, 8.h)

            Spacer(minLength: 110.h)

            npsCard
                .padding(.horizontal, 38.w)

            if showSubmitError {
                submitErrorText
                    .padding(.top, 18.h)
            }

            Spacer(minLength: 58.h)
        }
    }

    private var successMark: some View {
        ZStack {
            Circle()
                .fill(Color(AppColors.ctaGreen).opacity(0.32))
                .frame(width: 180.w, height: 180.w)

            Circle()
                .fill(Color(red: 0.47, green: 0.78, blue: 0.0))
                .frame(width: 140.w, height: 140.w)

            Image(systemName: "checkmark")
                .font(.system(size: 56.sp, weight: .black))
                .foregroundColor(Color(AppColors.black))
        }
    }

    private var npsCard: some View {
        VStack(spacing: 18.h) {
            Text(ResultScreenStrings.PostSession.npsEyebrow)
                .font(.system(size: 25.sp, weight: .semibold))
                .foregroundColor(Color(AppColors.primary))

            buildSemiBoldText(ResultScreenStrings.PostSession.npsQuestion, 32.sp, color: Color(AppColors.black))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            HStack(spacing: 13.w) {
                ForEach(1...10, id: \.self) { score in
                    scoreButton(score)
                }
            }
            .padding(.top, 8.h)

            HStack {
                Text(ResultScreenStrings.PostSession.notLikely)
                Spacer()
                Text(ResultScreenStrings.PostSession.extremelyLikely)
            }
            .font(.system(size: 22.sp, weight: .regular))
            .foregroundColor(Color(AppColors.black))
            .padding(.horizontal, 10.w)
        }
        .padding(.horizontal, 20.w)
        .padding(.vertical, 44.h)
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
                .font(.system(size: selectedScore == score ? 32.sp : 24.sp, weight: .bold))
                .foregroundColor(Color(AppColors.primary))
                .frame(maxWidth: .infinity)
                .frame(height: 80.h)
                .background(selectedScore == score ? Color(AppColors.ctaGreen) : Color(AppColors.formBorder).opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 6.r, style: .continuous)
                        .stroke(selectedScore == score ? Color(red: 0.35, green: 0.63, blue: 0.0) : Color(AppColors.formBorder), lineWidth: selectedScore == score ? 3.w : 1.w)
                )
                .clipShape(RoundedRectangle(cornerRadius: 6.r, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var footer: some View {
        VStack(spacing: 16.h) {
            if step == .nextSteps {
                weightedNextStepsFooter
            } else {
                HStack(alignment: .top, spacing: 20.w) {
                    Button(action: {
                        submitUserResponse(nextSteps: selectedResponses, npsScore: nil, action: .npsSkip)
                    }) {
                        ZStack {
                            footerText(ResultScreenStrings.PostSession.skip, width: 250.w, foreground: Color(AppColors.black), background: Color(AppColors.white), bordered: true)
                                .opacity(activeSubmissionAction == .npsSkip ? 0 : 1)

                            if activeSubmissionAction == .npsSkip {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(AppColors.black)))
                            }
                        }
                    }
                    .disabled(isSubmitting)

                    Spacer(minLength: 24.w)

                    Button(action: primaryAction) {
                        ZStack {
                            footerText(
                                ResultScreenStrings.PostSession.submitAndReturnHome,
                                width: 680.w,
                                foreground: Color(AppColors.black),
                                background: Color(AppColors.ctaGreen),
                                bordered: false
                            )
                            .opacity(activeSubmissionAction == .npsSubmit ? 0 : 1)

                            if activeSubmissionAction == .npsSubmit {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(AppColors.black)))
                            }
                        }
                    }
                    .disabled(isSubmitting || selectedScore == nil)
                    .opacity(selectedScore != nil ? 1 : 0.55)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24.h)
        .padding(.horizontal, 30.w)
        .padding(.bottom, 24.h)
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

    private var weightedNextStepsFooter: some View {
        GeometryReader { proxy in
            let outerSpacing = 20.w
            let innerSpacing = 16.w
            let availableWidth = proxy.size.width - outerSpacing - innerSpacing
            let totalWeight: CGFloat = 9.5
            let utilityWidth = availableWidth * (2 / totalWeight)
            let continueWidth = availableWidth * (5.5 / totalWeight)

            HStack(alignment: .top, spacing: outerSpacing) {
                    footerUtilityButton(
                        title: ResultScreenStrings.Actions.back.uppercased(),
                        width: utilityWidth,
                        action: {
                            navigateBackFromPostSessionFlow()
                        }
                    )
                    .disabled(isSubmitting)
                    footerUtilityButton(
                        title: ResultScreenStrings.PostSession.skip.uppercased(),
                        width: utilityWidth,
                        action: {
                            navigateToHome(showResponseToast: false)
                        }
                    )
                    .disabled(isSubmitting)


                footerPrimaryButton(
                    title: ResultScreenStrings.PostSession.continueTitle,
                    width: continueWidth,
                    action: primaryAction
                )
                .disabled(selectedOptionIDs.isEmpty || isSubmitting)
                .opacity((selectedOptionIDs.isEmpty || isSubmitting) ? 0.55 : 1)
            }
        }
        .frame(height: 72.h)
    }

    private func footerUtilityButton(title: String, width: CGFloat, isLoading: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(AppColors.black)))
                }
            }
            .font(.system(size: 20.sp, weight: .semibold))
            .foregroundColor(Color(AppColors.black))
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .frame(width: width)
            .frame(minHeight: 90.h)
            .background(Color(AppColors.white))
            .overlay(
                RoundedRectangle(cornerRadius: 12.r, style: .continuous)
                    .stroke(Color(AppColors.black).opacity(0.7), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12.r, style: .continuous))
        }
    }

    private var submitErrorText: some View {
        Text(ResultScreenStrings.PostSession.submitFailure)
            .font(.system(size: 16.sp, weight: .semibold))
            .foregroundColor(Color(AppColors.error))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
    

    private func footerPrimaryButton(title: String, width: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12.w) {
                Text(title)
                Image(systemName: "arrow.right")
            }
            .font(.system(size: 28.sp, weight: .semibold))
            .foregroundColor(Color(AppColors.black))
            .frame(width: width)
            .frame(minHeight: 90.h)
            .background(Color(AppColors.ctaGreen))
            .clipShape(RoundedRectangle(cornerRadius: 12.r, style: .continuous))
        }
    }

    private func footerText(_ text: String, width: CGFloat, foreground: Color, background: Color, bordered: Bool) -> some View {
        Text(text)
            .font(.system(size: 28.sp, weight: .semibold))
            .foregroundColor(foreground)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .frame(width: width)
            .frame(minHeight: 80.h)
            .background(background)
            .overlay(
                RoundedRectangle(cornerRadius: 12.r, style: .continuous)
                    .stroke(bordered ? Color(AppColors.black).opacity(0.7) : Color.clear, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12.r, style: .continuous))
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
            guard !selectedOptionIDs.isEmpty else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                step = .nps
            }
        case .nps:
            submitUserResponse(nextSteps: selectedResponses, npsScore: selectedScore, action: .npsSubmit)
        }
    }

    private func submitUserResponse(nextSteps: [KioskNextStepResponse], npsScore: Int?, action: PostSessionSubmissionAction) {
        guard !isSubmitting else { return }

        Task {
            await MainActor.run {
                isSubmitting = true
                activeSubmissionAction = action
                showSubmitError = false
            }

            do {
                guard let email = LocalUserStorage.loadEmail()?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !email.isEmpty else {
                    throw AppAPIError.missingSavedUser
                }

                _ = try await submissionService.sendUserResponse(
                    email: email,
                    nextSteps: nextSteps,
                    npsScore: npsScore
                )

                await MainActor.run {
                    navigateToHome(showResponseToast: action == .npsSubmit)
                }
            } catch {
                print("Kiosk post-session response error:", error.localizedDescription)
                await MainActor.run {
                    isSubmitting = false
                    activeSubmissionAction = nil
                    showSubmitError = true
                }
            }
        }
    }
}
