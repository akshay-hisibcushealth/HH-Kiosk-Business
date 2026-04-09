import SwiftUI

struct ClientIDEntryScreen: View {
    @EnvironmentObject var appState: AppState
    @State private var clientID = ""
    @State private var showValidationError = false

    let onClientIDSaved: (String) -> Void

    var body: some View {
        ZStack {
            Image(AppIconNames.Asset.clientIdScreenBackground)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.black.opacity(0.18)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Hero copy that sits above the client login card.
                VStack(spacing: 12.h) {
                    buildSemiBoldText(
                        ClientIDScreenStrings.title,
                        38.sp,
                        color: Color(AppColors.white)
                    )
                    .multilineTextAlignment(.center)

                    Text(ClientIDScreenStrings.subtitle)
                        .font(.system(size: 32.sp))
                        .foregroundColor(Color(AppColors.white))
                }

                Spacer()

                // Main card where the kiosk asks for the client ID before continuing.
                VStack(alignment: .leading, spacing: 24.h) {
                    HStack {
                        Spacer()
                        buildSemiBoldText(
                            ClientIDScreenStrings.cardTitle,
                            36.sp,
                            color: Color(AppColors.white)
                        )
                        Spacer()
                    }
                    .padding(.bottom, 18.h)

                    VStack(alignment: .leading, spacing: 14.h) {
                        Text(ClientIDScreenStrings.fieldLabel)
                            .font(.system(size: 26.sp, weight: .semibold))
                            .foregroundColor(Color(AppColors.white))

                        // Using an explicit prompt keeps the placeholder readable on
                        // top of the custom dark field background.
                        TextField(
                            "",
                            text: $clientID,
                            prompt: Text(ClientIDScreenStrings.fieldPlaceholder)
                                .font(.system(size: 24.sp, weight: .regular))
                                .foregroundColor(Color(AppColors.clientIDFieldPlaceholder))
                        )
                            .font(.system(size: 24.sp))
                            .foregroundColor(Color(AppColors.white))
                            .padding(.horizontal, 24.w)
                            .frame(height: 90.h)
                            .background(Color(AppColors.clientIDFieldBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12.r)
                                    .stroke(
                                        Color(
                                            showValidationError
                                                ? AppColors.error
                                                : AppColors.clientIDFieldBorder
                                        ),
                                        lineWidth: 1.6
                                    )
                            )
                            .cornerRadius(12.r)
                            .tint(Color(AppColors.white))
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .submitLabel(.go)
                            .onChange(of: clientID) { _, newValue in
                                let normalizedValue = normalizeClientIDInput(newValue)
                                if normalizedValue != newValue {
                                    clientID = normalizedValue
                                }
                            }
                            .onSubmit {
                                saveClientIDAndContinue()
                            }

                        // Validation only appears after an attempted submit with no value.
                        if showValidationError {
                            Text(ClientIDScreenStrings.validationMessage)
                                .font(.system(size: 16.sp, weight: .medium))
                                .foregroundColor(Color(AppColors.clientIDValidationText))
                        }
                    }

                    // Primary CTA: save the client ID locally, then continue into the app.
                    Button(action: saveClientIDAndContinue) {
                        HStack {
                            Text(ClientIDScreenStrings.actionButton)
                                .font(.system(size: 28.sp, weight: .medium))
                                .multilineTextAlignment(.center)
                        }
                        .foregroundColor(Color(AppColors.white))
                        .frame(maxWidth: .infinity)
                        .frame(height: 90.h)
                        .background(Color(AppColors.primaryActionOrange))
                        .cornerRadius(12.r)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10.h)
                    .padding(.bottom, 24.h)
                }
                .padding(.horizontal, 64.w)
                .padding(.top, 24.h)
                .padding(.bottom, 50.h)
                .frame(width: Screen.width * 0.6)
                .background(Color(AppColors.clientIDDialogBackground))
                .cornerRadius(28.r)
                .shadow(color: Color.black.opacity(0.24), radius: 24, x: 0, y: 12)

                Spacer()
            }
            .padding(.horizontal, 40.w)
            .padding(.bottom, 270.h)
        }
        .onAppear {
            appState.dismissScreenSaver()
        }
    }

    // Trims the user input, validates it, persists it, then lets the parent
    // screen switch from the entry flow into the existing home flow.
    private func saveClientIDAndContinue() {
        let normalizedClientID = normalizeClientIDInput(clientID)
        clientID = normalizedClientID

        guard isValidClientID(normalizedClientID) else {
            showValidationError = true
            return
        }

        showValidationError = false
        LocalUserStorage.saveClientID(normalizedClientID)
        onClientIDSaved(normalizedClientID)
    }

    // The kiosk client code is an 8-character uppercase hexadecimal value
    // such as B92884B3.
    private func isValidClientID(_ clientID: String) -> Bool {
        let pattern = "^[A-F0-9]{8}$"
        return clientID.range(of: pattern, options: .regularExpression) != nil
    }

    // Keep the field aligned with the expected format by uppercasing input,
    // removing spaces, and limiting the value to 8 hexadecimal characters.
    private func normalizeClientIDInput(_ input: String) -> String {
        let uppercaseInput = input.uppercased()
        let filteredScalars = uppercaseInput.unicodeScalars.filter { scalar in
            CharacterSet(charactersIn: "ABCDEF0123456789").contains(scalar)
        }

        return String(String.UnicodeScalarView(filteredScalars).prefix(8))
    }
}
