import SwiftUI

struct ProfileEmailSection: View {
    @Binding var email: String?

    @State private var localEmail: String = ""
    @State private var showError = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(PhysicalAttributesScreenStrings.Form.emailLabel)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(Color(AppColors.black))

            TextField(PhysicalAttributesScreenStrings.Form.emailPlaceholder, text: $localEmail)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .submitLabel(.done)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(.plain)
                .foregroundColor(Color(AppColors.black))
                .padding(.vertical, 20.h)
                .padding(.horizontal, 16.w)
                .frame(maxWidth: .infinity)
                .background(Color(AppColors.white))
                .overlay(
                    RoundedRectangle(cornerRadius: 12.r)
                        .stroke(showError ? Color.red : Color(AppColors.black), lineWidth: 1)
                )
                .onChange(of: localEmail) { _, newValue in
                    email = newValue

                    if newValue.isEmpty {
                        showError = false
                    } else {
                        showError = !isValidEmail(newValue)
                    }
                }
                .onAppear {
                    localEmail = email ?? ""
                }
                .onChange(of: email) { _, newValue in
                    let resolvedEmail = newValue ?? ""
                    if localEmail != resolvedEmail {
                        localEmail = resolvedEmail
                    }
                }

            if showError {
                Text(PhysicalAttributesScreenStrings.Form.emailInlineError)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return predicate.evaluate(with: email)
    }
}
