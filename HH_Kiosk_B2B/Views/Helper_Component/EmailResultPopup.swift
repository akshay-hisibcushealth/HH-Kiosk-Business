import SwiftUI
import AnuraCore

struct EmailResultPopup: View {
    let results: [String: MeasurementResults.SignalResult]
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var pin = ""
    @State private var isLoading = false
    @State private var isEmailSent = false
    @State private var showEmailError = false

    private let submissionService: KioskSubmissionServiceProtocol
    private let inputBackground = Color(red: 0.89, green: 0.94, blue: 1.0)
    private let inputBorder = Color(red: 0.78, green: 0.82, blue: 0.88)

    init(
        results: [String: MeasurementResults.SignalResult],
        initialEmail: String? = LocalUserStorage.loadUser()?.email,
        submissionService: KioskSubmissionServiceProtocol = KioskSubmissionService()
    ) {
        self.results = results
        self.submissionService = submissionService
        _email = State(initialValue: initialEmail ?? "")
    }

    private var isEmailValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }

    private var isPinValid: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", #"^\d{4}$"#)
        return predicate.evaluate(with: pin)
    }

    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()

            ZStack(alignment: .topTrailing) {
                if !isEmailSent && !isLoading {
                    Button(action: { dismiss() }) {
                        Image(systemName: AppIconNames.Symbol.xmark)
                            .font(.system(size: 36.sp, weight: .light))
                            .foregroundColor(Color(AppColors.black).opacity(0.65))
                            .frame(width: 56.w, height: 56.w)
                    }
                    .padding(.top, 44.h)
                    .padding(.trailing, 42.w)
                }

                VStack(spacing: 0) {
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(AppColors.gray)))
                            .scaleEffect(2)
                        Spacer()
                    } else if isEmailSent {
                        emailSentView
                    } else {
                        emailFormView
                    }
                }
                .padding(.horizontal, 42.w)
                .padding(.vertical, 48.h)
            }
            .frame(width: 930.w, height: 800.h)
            .background(Color(AppColors.white))
            .clipShape(RoundedRectangle(cornerRadius: 22.r, style: .continuous))
        }
        .presentationBackground(Color.clear)
    }

    private var emailSentView: some View {
        VStack(spacing: 32.h) {
            Image(systemName: AppIconNames.Symbol.envelopeFill)
                .font(.system(size: 172.sp, weight: .semibold))
                .foregroundColor(Color(AppColors.ctaGreen))

            Text(ResultScreenStrings.EmailPopup.inboxTitle)
                .font(.system(size: 42.sp, weight: .bold))
                .foregroundColor(Color(AppColors.black))

            Text(ResultScreenStrings.EmailPopup.inboxMessage)
                .font(.system(size: 32.sp, weight: .medium))
                .foregroundColor(Color(AppColors.black))
                .multilineTextAlignment(.center)

            Button(action: {
                navigateToHome()
                dismiss()
            }) {
                Text(ResultScreenStrings.EmailPopup.returnHome)
                    .font(.system(size: 20.sp, weight: .bold))
                    .foregroundColor(Color(AppColors.black))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(AppColors.ctaGreen))
                    .clipShape(RoundedRectangle(cornerRadius: 10.r, style: .continuous))
            }
        }
    }

    private var emailFormView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(ResultScreenStrings.EmailPopup.title)
                .font(.custom("NewSpirit-SemiBold", size: 34.sp))
                .foregroundColor(Color(AppColors.primary))
                .padding(.bottom, 40.h)

            VStack(alignment: .leading, spacing: 8.h) {
                Text(ResultScreenStrings.EmailPopup.emailAddress)
                    .font(.system(size: 26.sp, weight: .regular))
                    .foregroundColor(Color(AppColors.black))

                TextField(ResultScreenStrings.EmailPopup.emailPlaceholder, text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .font(.system(size: 26.sp, weight: .regular))
                    .foregroundColor(Color(AppColors.black).opacity(0.78))
                    .padding(.horizontal, 24.w)
                    .frame(height: 76.h)
                    .background(inputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.r, style: .continuous))
                    .overlay(inputBorderOverlay)
            }
            .padding(.bottom, 58.h)

            VStack(alignment: .leading, spacing: 8.h) {
                Text(ResultScreenStrings.EmailPopup.pinTitle)
                    .font(.system(size: 26.sp, weight: .regular))
                    .foregroundColor(Color(AppColors.black))

                SecureField(ResultScreenStrings.EmailPopup.pinPlaceholder, text: $pin)
                    .keyboardType(.numberPad)
                    .font(.system(size: 26.sp, weight: .regular))
                    .foregroundColor(Color(AppColors.black))
                    .padding(.horizontal, 24.w)
                    .frame(height: 76.h)
                    .background(inputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.r, style: .continuous))
                    .overlay(inputBorderOverlay)
                    .onChange(of: pin) { _, newValue in
                        pin = String(newValue.prefix(4).filter { $0.isNumber })
                    }

                Text(ResultScreenStrings.EmailPopup.pinHelp)
                    .font(.system(size: 22.sp, weight: .regular))
                    .italic()
                    .foregroundColor(Color(AppColors.primary).opacity(0.72))
                    .padding(.top, 10.h)
            }
            .padding(.bottom, 42.h)

            Button(action: sendResults) {
                HStack(spacing: 20.w) {
                    Image(systemName: AppIconNames.Symbol.envelopeFill)
                        .font(.system(size: 30.sp, weight: .semibold))
                    Text(ResultScreenStrings.EmailPopup.sendMail)
                        .font(.system(size: 24.sp, weight: .bold))
                }
                .foregroundColor(Color(AppColors.black))
                .frame(maxWidth: .infinity)
                .frame(height: 88.h)
                .background((isEmailValid && isPinValid) ? Color(AppColors.ctaGreen) : Color(AppColors.ctaGreen).opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 14.r, style: .continuous))
            }
            .disabled(!(isEmailValid && isPinValid))
            .padding(.horizontal, 6.w)

            if showEmailError {
                HStack(spacing: 8.w) {
                    Image(systemName: AppIconNames.Symbol.exclamationmarkTriangleFill)
                    Text(ResultScreenStrings.EmailPopup.emailFailure)
                }
                .font(.system(size: 20.sp))
                .foregroundColor(Color(AppColors.error))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 30.h)
            } else {
                HStack(spacing: 14.w) {
                    Image(systemName: AppIconNames.Symbol.lockShield)
                        .font(.system(size: 28.sp, weight: .semibold))
                    Text(ResultScreenStrings.EmailPopup.secureAndPrivate)
                        .font(.system(size: 24.sp, weight: .regular))
                }
                .foregroundColor(Color(AppColors.blue))
                .frame(maxWidth: .infinity)
                .padding(.top, 38.h)
            }
        }
    }

    private var inputBorderOverlay: some View {
        RoundedRectangle(cornerRadius: 14.r, style: .continuous)
            .stroke(inputBorder, lineWidth: 1.5)
    }

    private func sendResults() {
        Task {
            isLoading = true
            showEmailError = false
            do {
                try await submissionService.sendEmailResults(email: email, pin: pin, results: results)
                isEmailSent = true
            } catch {
                showEmailError = true
            }
            isLoading = false
        }
    }
}
