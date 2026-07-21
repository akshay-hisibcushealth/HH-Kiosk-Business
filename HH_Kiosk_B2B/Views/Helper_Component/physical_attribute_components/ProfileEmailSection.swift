//
//  ProfileEmailSection.swift
//  HH_Kiosk_B2B
//
//  Created by Applite Solutions on 13/03/26.
//


import SwiftUI
import UIKit

struct ProfileEmailSection: View {

    @Binding var email: String?
    var focusedField: FocusState<PhysicalAttributesInputField?>.Binding

    @State private var localEmail: String = ""
    @State private var showError = false

    var body: some View {
        VStack(alignment: .leading) {

            Text(PhysicalAttributesScreenStrings.Form.emailLabel)
                .font(.system(size: 24.sp, weight: .bold))
                .foregroundColor(Color(AppColors.black))

            LocalizedEditMenuTextField(
                text: $localEmail,
                placeholder: PhysicalAttributesScreenStrings.Form.emailPlaceholder,
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                returnKeyType: .done,
                autocapitalizationType: .none,
                autocorrectionType: .no,
                spellCheckingType: .no,
                textColor: AppColors.black,
                font: .systemFont(ofSize: 28.sp, weight: .regular),
                placeholderColor: AppColors.physicalAttributeFieldPlaceholder,
                placeholderFont: .systemFont(ofSize: 28.sp, weight: .regular),
                isFocused: focusedField.wrappedValue == .email,
                onFocusChange: { isFocused in
                    focusedField.wrappedValue = isFocused ? .email : nil
                },
                onReturn: {
                    focusedField.wrappedValue = nil
                    hideKeyboard()
                }
            )
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
