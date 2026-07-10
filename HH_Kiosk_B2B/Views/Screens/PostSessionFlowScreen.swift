import SwiftUI

private enum PostSessionStep {
    case nextSteps
    case nps
}

private enum PostSessionSelectionMode {
    case single
    case multiple
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

    init(id: Int, title: String, responseTitle: String = "") {
        self.id = id
        self.displayTitle = title
        self.responseTitle = responseTitle
        self.description = title
    }

    var response: KioskNextStepResponse {
        KioskNextStepResponse(id: id, title: responseTitle, description: description)
    }
}

private struct PostSessionQuestion: Identifiable, Equatable {
    let id: Int
    let title: String
    let question: String
    let selectionMode: PostSessionSelectionMode
    let options: [PostSessionNextStepOption]
    let disclaimer: String?
}

struct PostSessionFlowScreen: View {
    let emailWasSent: Bool

    @State private var step: PostSessionStep = .nextSteps
    @State private var currentQuestionIndex = 0
    @State private var selectedOptionIDsByQuestion: [Int: Set<Int>] = [:]
    @State private var selectedScore: Int?
    @State private var isSubmitting = false
    @State private var activeSubmissionAction: PostSessionSubmissionAction?
    @State private var showSubmitError = false

    private let submissionService: KioskSubmissionServiceProtocol = KioskSubmissionService()

    init(emailWasSent: Bool = false) {
        self.emailWasSent = emailWasSent
    }

    private var questions: [PostSessionQuestion] {
        typealias Questions = ResultScreenStrings.PostSession.Questions

        return [
            PostSessionQuestion(
                id: 0,
                title: Questions.LastHealthCheck.title,
                question: Questions.LastHealthCheck.question,
                selectionMode: .single,
                options: [
                    PostSessionNextStepOption(id: 0, title: Questions.LastHealthCheck.sixToTwelveMonths),
                    PostSessionNextStepOption(id: 1, title: Questions.LastHealthCheck.oneToTwoYearsAgo),
                    PostSessionNextStepOption(id: 2, title: Questions.LastHealthCheck.moreThanTwoYears),
                    PostSessionNextStepOption(id: 3, title: Questions.LastHealthCheck.never)
                ],
                disclaimer: nil
            ),
            PostSessionQuestion(
                id: 1,
                title: Questions.ScanLearning.title,
                question: Questions.ScanLearning.question,
                selectionMode: .single,
                options: [
                    PostSessionNextStepOption(id: 0, title: Questions.ScanLearning.surprised),
                    PostSessionNextStepOption(id: 1, title: Questions.ScanLearning.somewhatNew),
                    PostSessionNextStepOption(id: 2, title: Questions.ScanLearning.expected)
                ],
                disclaimer: nil
            ),
            PostSessionQuestion(
                id: 2,
                title: Questions.NextAction.title,
                question: Questions.NextAction.question,
                selectionMode: .multiple,
                options: [
                    PostSessionNextStepOption(id: 0, title: Questions.NextAction.bookDoctorVisit),
                    PostSessionNextStepOption(id: 1, title: Questions.NextAction.getBloodTests),
                    PostSessionNextStepOption(id: 2, title: Questions.NextAction.monitorMyHealth),
                    PostSessionNextStepOption(id: 3, title: Questions.NextAction.changeRoutine),
                    PostSessionNextStepOption(id: 4, title: Questions.NextAction.nothingRightNow)
                ],
                disclaimer: Questions.NextAction.disclaimer
            ),
            PostSessionQuestion(
                id: 3,
                title: Questions.FollowUp.title,
                question: Questions.FollowUp.question,
                selectionMode: .single,
                options: [
                    PostSessionNextStepOption(id: 0, title: Questions.FollowUp.yes),
                    PostSessionNextStepOption(id: 1, title: Questions.FollowUp.no)
                ],
                disclaimer: nil
            )
        ]
    }

    private var currentQuestion: PostSessionQuestion {
        questions[min(currentQuestionIndex, questions.count - 1)]
    }

    private var currentSelection: Set<Int> {
        selectedOptionIDsByQuestion[currentQuestion.id] ?? []
    }

    private var selectedResponses: [KioskNextStepResponse] {
        questions.compactMap { question in
            let selectedIDs = selectedOptionIDsByQuestion[question.id] ?? []
            let selectedDescriptions = question.options
                .filter { selectedIDs.contains($0.id) }
                .map(\.description)

            guard !selectedDescriptions.isEmpty else { return nil }

            return KioskNextStepResponse(
                id: question.id,
                title: question.question,
                description: selectedDescriptions.joined(separator: " | ")
            )
        }
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

    private var nextStepsContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            questionContent(currentQuestion)

            Spacer()

            if showSubmitError {
                submitErrorText
                    .padding(.horizontal, 58.w)
                    .padding(.bottom, 20.h)
            }
        }
    }

    private func questionContent(_ question: PostSessionQuestion) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            buildSemiBoldText(question.title, 36.sp, color: Color(AppColors.black))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(question.question)
                .font(.system(size: 32.sp, weight: .regular))
                .foregroundColor(Color(AppColors.black))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 28.h)

            VStack(spacing: 22.h) {
                ForEach(question.options) { option in
                    optionRow(option, in: question)
                        .disabled(isSubmitting)
                }
            }
            .padding(.top, 54.h)

            if let disclaimer = question.disclaimer {
                Text(disclaimer)
                    .font(.system(size: 24.sp,).italic())
                    .foregroundColor(Color(AppColors.resultTitleText))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 16.h)
                    .padding(.horizontal, 22.w)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(AppColors.infoPanelBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 4.r, style: .continuous))
                    .padding(.top, 24.h)
            }
        }
        .padding(.top, 58.h)
        .padding(.horizontal, 58.w)
    }

    private func optionRow(_ option: PostSessionNextStepOption, in question: PostSessionQuestion) -> some View {
        let isSelected = selectedOptionIDsByQuestion[question.id, default: []].contains(option.id)
        let selectedBorderColor = Color(AppColors.borderColor)

        return Button {
            toggleOption(option, in: question)
        } label: {
            HStack(spacing: 22.w) {
                if question.selectionMode == .multiple {
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
                }

                Text(option.displayTitle)
                    .font(.system(size: 28.sp, weight: isSelected ? .bold : .regular))
                    .foregroundColor(Color(AppColors.black))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)

                Spacer(minLength: 0)
            }
            .padding(.vertical, 32.h)
            .padding(.horizontal, 28.w)
            .frame(minHeight: 120.h)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color(AppColors.ctaGreen).opacity(0.12) : Color(AppColors.white))
            .overlay(
                RoundedRectangle(cornerRadius: 6.r, style: .continuous)
                    .stroke(isSelected ? selectedBorderColor : Color(AppColors.gray).opacity(0.45), lineWidth: isSelected ? 2.5 : 1.5)
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

            Text(ResultScreenStrings.PostSession.allDoneTitle)
                .font(.custom("NewSpirit-Medium", size: 36.sp))
                .foregroundColor(Color(AppColors.black))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 18.h)

 

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
                weightedNPSFooter
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
            let availableWidth = proxy.size.width - outerSpacing
            let totalWeight: CGFloat = 7.5
            let utilityWidth = availableWidth * (2 / totalWeight)
            let continueWidth = availableWidth * (5.5 / totalWeight)

            HStack(alignment: .top, spacing: outerSpacing) {
                footerUtilityButton(
                    title: ResultScreenStrings.Actions.back,
                    width: utilityWidth,
                    action: secondaryAction
                )
                .disabled(isSubmitting)

                footerPrimaryButton(
                    title: ResultScreenStrings.PostSession.continueTitle,
                    width: continueWidth,
                    action: primaryAction
                )
                .disabled(isSubmitting)
            }
        }
        .frame(height: 72.h)
    }

    private var weightedNPSFooter: some View {
        GeometryReader { proxy in
            let outerSpacing = 32.w
            let availableWidth = proxy.size.width - outerSpacing
            let totalWeight: CGFloat = 7.5
            let skipWidth = availableWidth * (2 / totalWeight)
            let submitWidth = availableWidth * (5.5 / totalWeight)

            HStack(alignment: .top, spacing: outerSpacing) {
                Button(action: {
                    submitUserResponse(nextSteps: selectedResponses, npsScore: nil, action: .npsSkip)
                }) {
                    ZStack {
                        footerText(
                            ResultScreenStrings.PostSession.skip,
                            width: skipWidth,
                            foreground: Color(AppColors.black),
                            background: Color(AppColors.white),
                            bordered: true
                        )
                        .opacity(activeSubmissionAction == .npsSkip ? 0 : 1)

                        if activeSubmissionAction == .npsSkip {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(AppColors.black)))
                        }
                    }
                }
                .disabled(isSubmitting)

                Button(action: primaryAction) {
                    ZStack {
                        footerText(
                            ResultScreenStrings.PostSession.submitAndReturnHome,
                            width: submitWidth,
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
        .frame(height: 80.h)
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

    private func toggleOption(_ option: PostSessionNextStepOption, in question: PostSessionQuestion) {
        var selectedIDs = selectedOptionIDsByQuestion[question.id] ?? []

        switch question.selectionMode {
        case .single:
            selectedIDs = [option.id]
        case .multiple:
            if selectedIDs.contains(option.id) {
                selectedIDs.remove(option.id)
            } else {
                selectedIDs.insert(option.id)
            }
        }

        selectedOptionIDsByQuestion[question.id] = selectedIDs
    }

    private func secondaryAction() {
        switch step {
        case .nextSteps:
            if currentQuestionIndex == 0 {
                navigateBackFromPostSessionFlow()
            } else {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentQuestionIndex -= 1
                }
            }
        case .nps:
            withAnimation(.easeInOut(duration: 0.2)) {
                step = .nextSteps
                currentQuestionIndex = max(questions.count - 1, 0)
            }
        }
    }

    private func primaryAction() {
        switch step {
        case .nextSteps:
            if currentQuestionIndex < questions.count - 1 {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentQuestionIndex += 1
                }
            } else {
                withAnimation(.easeInOut(duration: 0.2)) {
                    step = .nps
                }
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
                    navigateToHome(showResponseToast: true)
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
