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
                .frame(height: 28.h)
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
                            LocalizedEditMenuTextField(
                                text: $pin,
                                placeholder: ResultScreenStrings.EmailPopup.pinPlaceholder,
                                returnKeyType: .done,
                                autocorrectionType: .no,
                                spellCheckingType: .no,
                                textColor: AppColors.clear,
                                font: UIFont(name: "NewSpirit-SemiBold", size: 30.sp) ?? .systemFont(ofSize: 30.sp, weight: .semibold)
                            )
                                .frame(height: 30.h)
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
            try await submissionService.sendEmailResults(email: email, pin: pin)
            return true
        } catch {
            print("❌ Network error:", error.localizedDescription)
            return false
        }
    }
}
