import SwiftUI
import Foundation
import AnuraCore
import UIKit

struct EmailResultPopup: View {
    let results: [String: MeasurementResults.SignalResult]
    @Environment(\.dismiss) var dismiss
    private let submissionService: KioskSubmissionServiceProtocol
    @Binding private var isEmailSent: Bool
    @State private var email: String = UserDefaults.standard.string(forKey: "user_email") ?? ""
    @State private var pin: String = ""
    @State private var isLoading: Bool = false
    @FocusState private var isPinFocused: Bool
    @State private var showEmailError: Bool = false

    init(
        results: [String: MeasurementResults.SignalResult],
        isEmailSent: Binding<Bool> = .constant(false),
        submissionService: KioskSubmissionServiceProtocol = KioskSubmissionService()
    ) {
        self.results = results
        self._isEmailSent = isEmailSent
        self.submissionService = submissionService
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
        ZStack {
            VStack(spacing: 16.h) {
                if isLoading {
                    loadingView
                } else if isEmailSent {
                    emailSentView
                } else {
                    emailFormView
                }
            }
            .padding(.top, 20.h)

            if !isEmailSent {
                closeButton
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, 42.h)
                    .padding(.trailing, 58.w)
            }
        }
    }

    @ViewBuilder
    private var closeButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: AppIconNames.Symbol.xmark)
                .font(.system(size: 28.sp, weight: .medium))
                .foregroundColor(Color(AppColors.black))
                .frame(width: 58.w, height: 58.w)
                .contentShape(Rectangle())
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
        Spacer()

        Image(AppIconNames.Asset.emailSent)
            .resizable()
            .scaledToFit()
            .frame(width: 160.w, height: 160.w)
            .padding(.bottom, 12.h)

        Text(ResultScreenStrings.EmailPopup.checkInboxTitle)
            .font(.system(size: 28.sp, weight: .bold))
            .foregroundColor(Color(AppColors.black))
            .padding(.bottom, 14.h)

        Text(ResultScreenStrings.EmailPopup.emailSentMessage)
            .multilineTextAlignment(.center)
            .font(.system(size: 24.sp))
            .foregroundColor(Color(AppColors.black))
            .lineSpacing(4.h)
            .padding(.bottom, 24.h)

        Button(action: {
            dismiss()
        }) {
            Text(ResultScreenStrings.EmailPopup.done)
                .foregroundColor(Color(AppColors.black))
                .font(.system(size: 22.sp, weight: .bold))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(AppColors.ctaGreen))
                .cornerRadius(10.r)
        }
        .padding(.horizontal, 44.w)

        Spacer()
    }

    @ViewBuilder
    private var emailFormView: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color(AppColors.ctaGreen).opacity(0.30))
                    .frame(width: 104.w, height: 104.w)

                Image(systemName: "envelope")
                    .font(.system(size: 40.sp, weight: .medium))
                    .foregroundColor(Color(AppColors.primary))
            }
            .padding(.bottom, 22.h)

            Text(ResultScreenStrings.EmailPopup.title)
                .font(.custom("NewSpirit-Semibold", size: 36.sp))
                .foregroundColor(Color(AppColors.black))
                .padding(.bottom, 8.h)

            Text(ResultScreenStrings.EmailPopup.subtitle)
                .font(.system(size: 22.sp, weight: .regular))
                .foregroundColor(Color(AppColors.black))
                .multilineTextAlignment(.center)
                .lineSpacing(4.h)
                .padding(.bottom, 36.h)

            VStack(alignment: .leading, spacing: 24.h) {
                VStack(alignment: .leading, spacing: 12.h) {
                    Text(ResultScreenStrings.EmailPopup.emailAddress)
                        .font(.system(size: 22.sp, weight: .bold))
                        .foregroundColor(Color(AppColors.black))

                    LocalizedEditMenuTextField(
                        text: $email,
                        placeholder: ResultScreenStrings.EmailPopup.emailPlaceholder,
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        returnKeyType: .done,
                        autocapitalizationType: .none,
                        autocorrectionType: .no,
                        spellCheckingType: .no,
                        textColor: AppColors.black
                    )
                    .frame(height: 34.h)
                    .padding(.vertical, 22.h)
                    .padding(.horizontal, 20.w)
                    .background(Color(uiColor: .systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10.r, style: .continuous)
                            .stroke(Color(AppColors.formBorder), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10.r, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 12.h) {
                    Text(ResultScreenStrings.EmailPopup.pinTitle)
                        .font(.system(size: 22.sp, weight: .bold))
                        .foregroundColor(Color(AppColors.black))

                    LocalizedEditMenuTextField(
                        text: $pin,
                        placeholder: ResultScreenStrings.EmailPopup.pinPlaceholder,
                        returnKeyType: .done,
                        autocorrectionType: .no,
                        spellCheckingType: .no,
                        textColor: AppColors.black,
                        font: .systemFont(ofSize: 28.sp, weight: .semibold),
                        masksTextImmediately: true
                    )
                    .frame(height: 34.h)
                    .padding(.vertical, 22.h)
                    .padding(.horizontal, 20.w)
                    .onChange(of: pin) { _, newValue in
                        pin = String(newValue.prefix(4).filter(\.isNumber))
                    }
                    .background(Color(uiColor: .systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10.r, style: .continuous)
                            .stroke(Color(AppColors.formBorder), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10.r, style: .continuous))
                }
            }

            Button {
                Task {
                    isLoading = true
                    let success = await submitEmailResults()
                    isLoading = false
                    if success {
                        isEmailSent = true
                    } else {
                        showEmailError = true
                    }
                }
            } label: {
                HStack(spacing: 14.w) {
                    Image(systemName: AppIconNames.Symbol.paperplane)
                        .font(.system(size: 24.sp, weight: .medium))

                    Text(ResultScreenStrings.EmailPopup.sendMail)
                        .font(.system(size: 22.sp, weight: .bold))
                }
                .foregroundColor(Color(AppColors.black))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 82.h)
                .background(
                    (isEmailValid && isPinValid)
                        ? Color(AppColors.ctaGreen)
                        : Color(AppColors.ctaGreen).opacity(0.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10.r, style: .continuous))
            }
            .disabled(!(isEmailValid && isPinValid))
            .padding(.top, 30.h)

            if showEmailError {
                HStack(spacing: 8.w) {
                    Image(systemName: AppIconNames.Symbol.exclamationmarkTriangleFill)
                    Text(ResultScreenStrings.EmailPopup.emailFailure)
                        .multilineTextAlignment(.center)
                }
                .font(.system(size: 18.sp))
                .foregroundColor(Color(AppColors.error))
                .padding(.top, 14.h)
            }
        }
        .padding(.horizontal, 70.w)
        .padding(.top, 68.h)
        .padding(.bottom, 100.h)
    }

    private func submitEmailResults() async -> Bool {
        do {
            try await submissionService.sendEmailResults(email: email, pin: pin)
            return true
        } catch {
            print("❌ Network error:", error.localizedDescription)
            return false
        }
    }
}
