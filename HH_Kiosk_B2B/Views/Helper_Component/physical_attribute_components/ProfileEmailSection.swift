//
//  ProfileEmailSection.swift
//  HH_Kiosk_B2B
//
//  Created by Applite Solutions on 13/03/26.
//


import SwiftUI

struct ProfileEmailSection: View {

    @Binding var email: String?
    var focusedField: Binding<PhysicalAttributesInputField?>

    @State private var localEmail: String = ""
    @State private var showError = false

    var body: some View {
        VStack(alignment: .leading) {

            Text(PhysicalAttributesScreenStrings.Form.emailLabel)
                .font(.system(size: 24.sp, weight: .bold))
                .foregroundColor(Color(AppColors.black))

            KioskTextField(
                text: $localEmail,
                isFocused: PhysicalAttributesInputField.email.focusBinding(in: focusedField),
                placeholder: PhysicalAttributesScreenStrings.Form.emailPlaceholder,
                title: PhysicalAttributesScreenStrings.Form.emailLabel,
                kind: .email,
                onDone: { focusedField.wrappedValue = .pin }
            )
                .frame(height: 34.h)
                .padding(.vertical, 26.h)
                .padding(.horizontal, 28.w)
                .frame(maxWidth: .infinity, minHeight: 94.h)
                .background(
                    localEmail.isEmpty
                        ? Color(AppColors.physicalAttributeFieldBackground)
                        : Color(AppColors.white)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12.r, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12.r)
                        .stroke(
                            showError ? Color.red : Color(AppColors.physicalAttributeFieldBorder),
                            lineWidth: 1.5
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
                .onAppear {
                    localEmail = email ?? ""
                }
                .onChange(of: email) { _, newValue in
                    let resolvedEmail = newValue ?? ""
                    if localEmail != resolvedEmail {
                        localEmail = resolvedEmail
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .physicalAttributesDismissInputFocus)) { _ in
                    focusedField.wrappedValue = nil
                    hideKeyboard()
                }

            if showError {
                Text(PhysicalAttributesScreenStrings.Form.emailInlineError)
                    .font(.system(size: 16.sp, weight: .regular))
                    .foregroundColor(.red)
            }
        }
        .physicalAttributeScrollTarget(.email)
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
