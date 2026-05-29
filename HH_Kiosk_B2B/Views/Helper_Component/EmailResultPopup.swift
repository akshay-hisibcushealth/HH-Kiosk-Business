import SwiftUI
import Foundation
import AnuraCore
import UIKit

struct EmailResultPopup: View {
    let results: [String: MeasurementResults.SignalResult]
    @Environment(\.dismiss) var dismiss
    private let submissionService: KioskSubmissionServiceProtocol
    @Binding private var usesPromptSelectionLayout: Bool
    @State private var email: String = UserDefaults.standard.string(forKey: "user_email") ?? ""
    @State private var pin: String = ""
    @State private var isLoading: Bool = false
    @State private var isEmailSent: Bool = false
    @FocusState private var isPinFocused: Bool
    @State private var showEmailError: Bool = false

    init(
        results: [String: MeasurementResults.SignalResult],
        submissionService: KioskSubmissionServiceProtocol = KioskSubmissionService(),
        usesPromptSelectionLayout: Binding<Bool> = .constant(false)
    ) {
        self.results = results
        self.submissionService = submissionService
        self._usesPromptSelectionLayout = usesPromptSelectionLayout
    }


    // Email validation
    private var isEmailValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }

    // Pin validation
    private var isPinValid: Bool {
        let pinRegex = #"^\d{4}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", pinRegex)
        return predicate.evaluate(with: pin)
    }


    
    var body: some View {
        Group {
            if isEmailSent {
                emailSentView
            } else {
                ZStack(alignment: .topTrailing) {
                    closeButton
                        .padding(.top, 16.h)
                        .padding(.trailing, 16.w)

                    VStack(spacing: 16.h) {
                        if isLoading {
                            loadingView
                        } else {
                            emailFormView
                        }
                    }
                    .padding(.top, 20.h)
                }
            }
        }
        .onAppear {
            usesPromptSelectionLayout = isEmailSent
        }
    }

    @ViewBuilder
    private var closeButton: some View {
        Button(action: { dismiss() }) {
            if !isEmailSent {
                HStack {
                    Spacer()
                    Image(systemName: AppIconNames.Symbol.xmark)
                        .padding(.trailing, 32.w)
                        .foregroundColor(Color(AppColors.black))
                }
            }
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        Spacer()
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(AppColors.gray)))
                .scaleEffect(2)
            Spacer()
        }
        Spacer()
    }

    @ViewBuilder
    private var emailSentView: some View {
        NextStepsPromptView(
            mode: .emailSent,
            closeAction: {
                dismiss()
            },
            confirmAction: { title, description in
                await submitUserResponse(title: title, description: description)
            }
        )
    }

    @ViewBuilder
    private var emailFormView: some View {
        Image(AppIconNames.Asset.emailLock)
            .resizable()
            .scaledToFit()
            .padding(.top)
            .frame(width: 50.w, height: 60.h)

        Text(ResultScreenStrings.EmailPopup.title)
            .font(.headline)
            .bold()
            .padding(.bottom, 12)

        // Email field
        VStack(alignment: .leading) {
            Text(ResultScreenStrings.EmailPopup.emailAddress)
                .font(.headline)
                .padding(.horizontal)
                .foregroundColor(Color(AppColors.black))
            TextField(ResultScreenStrings.EmailPopup.emailPlaceholder, text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.vertical, 24.h)
                .padding(.horizontal)
                .background(RoundedRectangle(cornerRadius: 10.r).stroke(Color(AppColors.gray).opacity(0.3)))
                .padding(.horizontal)
        }
        

        // PIN field
                    VStack(alignment: .leading) {
                        Text(ResultScreenStrings.EmailPopup.pinTitle)
                            .font(.headline)
                            .padding(.horizontal)
                            .foregroundColor(Color(AppColors.black))

                        ZStack(alignment: .leading) {
                            // Background display of asterisks
                            HStack(spacing: 1.w) { // Set spacing to 0 if not already minimal
                                ForEach(0..<pin.count, id: \.self) { _ in
                                    Text("*")
                                        .font(.system(size: 24.sp,weight: .bold))
                                        .padding(.top,8.h)
                                        .padding(.trailing,4.h)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)

                            // The actual input field
                            TextField(ResultScreenStrings.EmailPopup.pinPlaceholder, text: $pin)
                                .foregroundColor(Color(AppColors.clear))
                                
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).stroke(Color(AppColors.gray).opacity(0.3)))
                                .onChange(of: pin) { _,newValue in
                                    pin = String(newValue.prefix(4).filter { $0.isNumber })
                                }

                        }
                        .font(.custom("NewSpirit-SemiBold", size: 30.sp))
                        // ========================================================================
                        .padding(.horizontal)

                        Text(ResultScreenStrings.EmailPopup.pinHelp)
                            .font(.caption)
                            .italic()
                            .padding(.horizontal)
                            .foregroundColor(Color(AppColors.blue))
                    }
        

        // Send button
        Button(action: {
            Task {
                isLoading = true
                let success = await submitEmailResults()
                isLoading = false
                if success {
                    usesPromptSelectionLayout = true
                    isEmailSent = true
                } else {
                    // Trigger failure message
                    showEmailError = true
                }
            }
        }) {
            HStack {
                Image(systemName: AppIconNames.Symbol.envelopeFill)
                    .foregroundColor(Color(AppColors.black))
                Text(ResultScreenStrings.EmailPopup.sendMail)
                    .foregroundColor(Color(AppColors.black))
                    .fontWeight(.bold)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background((isEmailValid && isPinValid) ? Color(AppColors.ctaGreen) : Color(AppColors.ctaGreen).opacity(0.5))
            .cornerRadius(10.r)
        }
        .disabled(!(isEmailValid && isPinValid))
        .padding(.horizontal)

        // ✅ Show message depending on success/failure
        if showEmailError {
            HStack(spacing: 8.w) {
                Image(systemName: AppIconNames.Symbol.exclamationmarkTriangleFill)
                    .foregroundColor(Color(AppColors.error))
                Text(ResultScreenStrings.EmailPopup.emailFailure)
                    .foregroundColor(Color(AppColors.error))
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8.h)
        } else {
            HStack(spacing: 8.w) {
                Image(systemName: AppIconNames.Symbol.lockShield)
                    .foregroundColor(Color(AppColors.blue))
                Text(ResultScreenStrings.EmailPopup.secureAndPrivate)
                    .foregroundColor(Color(AppColors.blue))
                    .font(.footnote)
            }
        }

    }

    private func submitEmailResults() async -> Bool {
        do {
            try await submissionService.sendEmailResults(email: email, pin: pin, results: results)
            return true
        } catch {
            print("❌ Network error:", error.localizedDescription)
            return false
        }
    }

    private func submitUserResponse(title: String, description: String) async -> Bool {
        let storedEmail = LocalUserStorage.loadEmail() ?? email
        guard !storedEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        do {
            _ = try await submissionService.sendUserResponse(
                email: storedEmail,
                title: title,
                description: description
            )
            await MainActor.run {
                dismiss()
                navigateToHome(showResponseToast: true)
            }
            return true
        } catch {
            print("❌ Kiosk user response error:", error.localizedDescription)
            return false
        }
    }
}

enum NextStepsPromptMode {
    case endSession
    case emailSent
}

private struct NextStepOption: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let responseDescription: String
    let assetName: String

    static func == (lhs: NextStepOption, rhs: NextStepOption) -> Bool {
        lhs.id == rhs.id
    }
}

struct NextStepsPromptView: View {
    let mode: NextStepsPromptMode
    let closeAction: () -> Void
    let confirmAction: (String, String) async -> Bool

    @State private var selectedOption: NextStepOption?
    @State private var isSubmittingResponse = false

    private var hasSelection: Bool {
        selectedOption != nil
    }

    private var canConfirm: Bool {
        selectedOption != nil && !isSubmittingResponse
    }

    private var options: [NextStepOption] {
        [
            NextStepOption(
                id: "doctor",
                title: ResultScreenStrings.EmailPopup.NextSteps.talkToDoctorTitle,
                subtitle: ResultScreenStrings.EmailPopup.NextSteps.talkToDoctorSubtitle,
                responseDescription: ResultScreenStrings.EmailPopup.NextSteps.talkToDoctorBodyPrefix
                    + ResultScreenStrings.EmailPopup.NextSteps.talkToDoctorLink
                    + ResultScreenStrings.EmailPopup.NextSteps.talkToDoctorBodySuffix,
                assetName: AppIconNames.Asset.nextStepDoctor
            ),
            NextStepOption(
                id: "dietitian",
                title: ResultScreenStrings.EmailPopup.NextSteps.dietitianTitle,
                subtitle: ResultScreenStrings.EmailPopup.NextSteps.dietitianSubtitle,
                responseDescription: ResultScreenStrings.EmailPopup.NextSteps.dietitianBody,
                assetName: AppIconNames.Asset.nextStepDietitian
            ),
            NextStepOption(
                id: "monitoring",
                title: ResultScreenStrings.EmailPopup.NextSteps.monitoringTitle,
                subtitle: ResultScreenStrings.EmailPopup.NextSteps.monitoringSubtitle,
                responseDescription: ResultScreenStrings.EmailPopup.NextSteps.monitoringBodyPrefix
                    + ResultScreenStrings.EmailPopup.NextSteps.monitoringCode
                    + ResultScreenStrings.EmailPopup.NextSteps.monitoringBodySuffix,
                assetName: AppIconNames.Asset.nextStepMonitoring
            )
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, mode == .emailSent ? 52.h : 68.h)
                .padding(.bottom, 82.h)

            VStack(spacing: 24.h) {
                ForEach(options) { option in
                    nextStepCard(option)
                }
            }
            .padding(.horizontal, 68.w)

            Spacer(minLength: 28.h)

            actionRow
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 72.w)
                .padding(.bottom, mode == .endSession ? 66.h : 64.h)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(AppColors.white))
    }

    @ViewBuilder
    private var header: some View {
        VStack(spacing: 18.h) {
            if mode == .emailSent {
                HStack(spacing: 14.w) {
                    Image(AppIconNames.Asset.emailSent)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 42.w, height: 42.w)

                    Text(ResultScreenStrings.EmailPopup.emailSentConfirmation)
                        .font(.system(size: 19.sp, weight: .regular))
                        .foregroundColor(Color(AppColors.black))
                }
                .padding(.bottom, 12.h)

                promptTitle(ResultScreenStrings.EmailPopup.whatNextTitle)
            } else {
                promptTitle(ResultScreenStrings.EmailPopup.oneLastThingTitle)
            }

            Text(ResultScreenStrings.EmailPopup.supportSubtitle)
                .font(.system(size: 22.sp, weight: .regular))
                .foregroundColor(Color(AppColors.black))
        }
        .frame(maxWidth: .infinity)
    }

    private func promptTitle(_ text: String) -> some View {
        buildSemiBoldText(text, 40.sp, color: Color(AppColors.black))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.85)
    }

    private func nextStepCard(_ option: NextStepOption) -> some View {
        let isSelected = selectedOption == option
        let isDimmed = hasSelection && !isSelected

        return VStack(alignment: .leading, spacing: isSelected ? 28.h : 0) {
            HStack(spacing: 24.w) {
                optionIcon(option, isDimmed: isDimmed)

                VStack(alignment: .leading, spacing: 10.h) {
                    buildSemiBoldText(
                        option.title,
                        26.sp,
                        color: isDimmed ? Color(AppColors.black).opacity(0.28) : Color(AppColors.black)
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                    if !isSelected {
                        Text(option.subtitle)
                            .font(.system(size: 19.sp, weight: .regular))
                            .foregroundColor(Color(AppColors.black).opacity(isDimmed ? 0.28 : 1))
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: isSelected ? "chevron.down" : AppIconNames.Symbol.chevronRight)
                    .font(.system(size: 22.sp, weight: .bold))
                    .foregroundColor(Color(AppColors.black).opacity(isDimmed ? 0.08 : 1))
                    .frame(width: 48.w, height: 48.w)
                    .background(Color(AppColors.indigo).opacity(isDimmed ? 0.04 : 0.12))
                    .clipShape(Circle())
            }

            if isSelected {
                expandedContent(for: option)
                    .padding(.leading, 0)
            }
        }
        .padding(.horizontal, 46.w)
        .padding(.vertical, isSelected ? 34.h : 0)
        .frame(maxWidth: .infinity)
        .frame(height: isSelected ? expandedHeight(for: option) : 138.h)
        .background(Color(AppColors.white))
        .overlay(
            RoundedRectangle(cornerRadius: 22.r, style: .continuous)
                .stroke(
                    isSelected ? Color(red: 0.0, green: 0.18, blue: 0.78) : Color(AppColors.gray).opacity(isDimmed ? 0.22 : 0.7),
                    lineWidth: isSelected ? 3 : 1
                )
        )
        .shadow(
            color: isSelected ? Color(AppColors.black).opacity(0.22) : Color.clear,
            radius: isSelected ? 8 : 0,
            x: 0,
            y: isSelected ? 4 : 0
        )
        .clipShape(RoundedRectangle(cornerRadius: 22.r, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 22.r, style: .continuous))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.22)) {
                selectedOption = isSelected ? nil : option
            }
        }
    }

    private func optionIcon(_ option: NextStepOption, isDimmed: Bool) -> some View {
        Image(option.assetName)
            .resizable()
            .renderingMode(.original)
            .scaledToFit()
            .frame(width: 38.w, height: 38.w)
            .opacity(isDimmed ? 0.32 : 1)
    }

    @ViewBuilder
    private func expandedContent(for option: NextStepOption) -> some View {
        switch option.id {
        case "doctor":
            doctorExpandedContent
        case "dietitian":
            Text(ResultScreenStrings.EmailPopup.NextSteps.dietitianBody)
                .font(.system(size: 21.sp, weight: .regular))
                .lineSpacing(13.h)
                .foregroundColor(Color(AppColors.black))
                .multilineTextAlignment(.leading)
        case "monitoring":
            HStack(alignment: .top, spacing: 26.w) {
                monitoringExpandedText
                    .font(.system(size: 20.sp, weight: .regular))
                    .lineSpacing(13.h)
                    .foregroundColor(Color(AppColors.black))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                qrCodeView
                    .frame(width: 185.w, height: 185.w)
                    .padding(.top, 2.h)
            }
        default:
            EmptyView()
        }
    }

    private var doctorExpandedContent: some View {
        Text(
            inlineLinkText(
            prefix: ResultScreenStrings.EmailPopup.NextSteps.talkToDoctorBodyPrefix,
            linkText: ResultScreenStrings.EmailPopup.NextSteps.talkToDoctorLink,
                suffix: ResultScreenStrings.EmailPopup.NextSteps.talkToDoctorBodySuffix
            )
        )
        .font(.system(size: 21.sp, weight: .regular))
        .lineSpacing(13.h)
        .foregroundColor(Color(AppColors.black))
        .multilineTextAlignment(.leading)
        .environment(\.openURL, OpenURLAction { url in
            UIApplication.shared.open(url)
            return .handled
        })
    }

    private var monitoringExpandedText: Text {
        Text(ResultScreenStrings.EmailPopup.NextSteps.monitoringBodyPrefix)
        + Text(ResultScreenStrings.EmailPopup.NextSteps.monitoringCode)
            .bold()
        + Text(ResultScreenStrings.EmailPopup.NextSteps.monitoringBodySuffix)
    }

    @ViewBuilder
    private var qrCodeView: some View {
        Image(AppIconNames.Asset.appsLinkQRCode)
            .resizable()
            .interpolation(.none)
            .scaledToFit()
    }

    private func expandedHeight(for option: NextStepOption) -> CGFloat {
        option.id == "monitoring" ? 330.h : 315.h
    }

    private var actionRow: some View {
        HStack(spacing: mode == .endSession ? 22.w : 20.w) {
            Button(action: closeAction) {
                Text(mode == .endSession ? ResultScreenStrings.Actions.endSession : ResultScreenStrings.EmailPopup.close)
                    .font(.system(size: 23.sp, weight: .bold))
                    .foregroundColor(mode == .endSession ? Color(AppColors.white) : Color(AppColors.primary))
                    .frame(width: mode == .endSession ? 350.w : 240.w)
                    .frame(height: 84.h)
                    .background(mode == .endSession ? Color(red: 0.71, green: 0.02, blue: 0.02) : Color(AppColors.black).opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 10.r, style: .continuous))
            }

            Button(action: handleConfirm) {
                ZStack {
                    Text(ResultScreenStrings.EmailPopup.confirm)
                        .opacity(isSubmittingResponse ? 0 : 1)

                    if isSubmittingResponse {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(AppColors.white)))
                    }
                }
                .font(.system(size: 23.sp, weight: .bold))
                .foregroundColor(Color(AppColors.white))
                .frame(width: mode == .endSession ? 272.w : 280.w)
                .frame(height: 84.h)
                .background(selectedOption != nil ? Color(red: 0.39, green: 0.76, blue: 0.0) : Color(red: 0.86, green: 0.94, blue: 0.75))
                .clipShape(RoundedRectangle(cornerRadius: 10.r, style: .continuous))
            }
            .disabled(!canConfirm)
            .opacity((selectedOption != nil || isSubmittingResponse) ? 1 : 0.86)
        }
    }

    private func handleConfirm() {
        guard let selectedOption, !isSubmittingResponse else { return }

        Task {
            await MainActor.run {
                isSubmittingResponse = true
            }
            let succeeded = await confirmAction(selectedOption.title, selectedOption.responseDescription)
            if !succeeded {
                await MainActor.run {
                    isSubmittingResponse = false
                }
            }
        }
    }

    private func inlineLinkText(prefix: String, linkText: String, suffix: String) -> AttributedString {
        var attributedText = AttributedString(prefix + linkText + suffix)

        if let range = attributedText.range(of: linkText),
           let url = URL(string: linkText) {
            attributedText[range].link = url
            attributedText[range].foregroundColor = Color(AppColors.primaryActionOrange)
            attributedText[range].underlineStyle = .single
            attributedText[range].font = .system(size: 21.sp, weight: .bold)
        }

        return attributedText
    }
}
