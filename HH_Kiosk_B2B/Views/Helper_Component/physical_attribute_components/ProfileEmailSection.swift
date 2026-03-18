import SwiftUI

struct ProfileEmailSection: View {

    @Binding var email: String?

    @State private var localEmail: String = ""
    @State private var showError = false

    var body: some View {
        VStack(alignment: .leading) {

            Text("Email")
                .font(.body)
                .fontWeight(.bold)

            TextField("Enter email", text: $localEmail)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .foregroundColor(Color(AppColors.black))
                .padding(.vertical, 20.h)
                .padding(.horizontal, 16.w)
                .background(Color(AppColors.white))
                .overlay(
                    RoundedRectangle(cornerRadius: 12.r)
                        .stroke(
                            showError ? Color.red : Color(AppColors.black),
                            lineWidth: 1
                        )
                )
                .onChange(of: localEmail) { _, newVal in

                    email = newVal

                    if newVal.isEmpty {
                        showError = false
                        return
                    }

                    showError = !isValidEmail(newVal)
                }

            if showError {
                Text("Enter a valid email address")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {

        let emailRegex =
        #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#

        let predicate = NSPredicate(
            format: "SELF MATCHES[c] %@",
            emailRegex
        )

        return predicate.evaluate(with: email)
    }
}