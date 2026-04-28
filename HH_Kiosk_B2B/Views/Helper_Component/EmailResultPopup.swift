import SwiftUI
import Foundation
import AnuraCore

struct EmailResultPopup: View {
    let results: [String: MeasurementResults.SignalResult]
    @Environment(\.dismiss) var dismiss
    private let submissionService: KioskSubmissionServiceProtocol
    @State private var email: String = UserDefaults.standard.string(forKey: "user_email") ?? ""
    @State private var pin: String = ""
    @State private var isLoading: Bool = false
    @State private var isEmailSent: Bool = false
    @FocusState private var isPinFocused: Bool
    @State private var showEmailError: Bool = false

    init(
        results: [String: MeasurementResults.SignalResult],
        submissionService: KioskSubmissionServiceProtocol = KioskSubmissionService()
    ) {
        self.results = results
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
        ZStack(alignment: .topTrailing) {
            closeButton
                .padding(.top, 16.h)
                .padding(.trailing, 16.w)

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
        Image(AppIconNames.Asset.emailSent)
            .resizable()
            .scaledToFit()
            .padding(.top)
            .frame(width: 120.w, height: 120.w)

        Text(ResultScreenStrings.EmailPopup.inboxTitle)
            .font(.title)
            .bold()
            .padding(.bottom, 24)

        Text(ResultScreenStrings.EmailPopup.inboxMessage)
            .font(.headline)
            .multilineTextAlignment(.center)
            .padding(.bottom, 12)

        Button(action: {
            navigateToHome()
            dismiss()
        }) {
            Text(ResultScreenStrings.EmailPopup.returnHome)
                .foregroundColor(Color(AppColors.black))
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(AppColors.accent))
                .cornerRadius(10)
        }
        .padding(.horizontal)
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
            .background((isEmailValid && isPinValid) ? Color(AppColors.accent) : Color(AppColors.accent).opacity(0.5))
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
}
