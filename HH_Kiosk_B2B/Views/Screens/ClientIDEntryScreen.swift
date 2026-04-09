import SwiftUI

struct ClientIDEntryScreen: View {
    @EnvironmentObject var appState: AppState
    @State private var clientID = ""
    @State private var validationErrorMessage: String?
    @State private var isValidating = false

    private let validationService: ClientCodeValidationServiceProtocol

    let onClientIDSaved: (String) -> Void

    init(
        onClientIDSaved: @escaping (String) -> Void,
        validationService: ClientCodeValidationServiceProtocol = ClientCodeValidationService()
    ) {
        self.onClientIDSaved = onClientIDSaved
        self.validationService = validationService
    }

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
                                            validationErrorMessage != nil
                                                ? AppColors.error
                                                : AppColors.clientIDFieldBorder
                                        ),
                                        lineWidth: 1.6
                                    )
                            )
                            .cornerRadius(12.r)
                            .tint(Color(AppColors.white))
                            .disabled(isValidating)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .submitLabel(.go)
                            .onChange(of: clientID) { _, newValue in
                                let normalizedValue = normalizeClientIDInput(newValue)
                                if normalizedValue != newValue {
                                    clientID = normalizedValue
                                }
                                if validationErrorMessage != nil {
                                    validationErrorMessage = nil
                                }
                            }
                            .onSubmit {
                                Task {
                                    await saveClientIDAndContinue()
                                }
                            }

                        // Validation only appears after an attempted submit with no value.
                        if let validationErrorMessage {
                            Text(validationErrorMessage)
                                .font(.system(size: 16.sp, weight: .medium))
                                .foregroundColor(Color(AppColors.clientIDValidationText))
                        }
                    }

                    // Primary CTA: save the client ID locally, then continue into the app.
                    Button {
                        Task {
                            await saveClientIDAndContinue()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if isValidating {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(Color(AppColors.white))
                            } else {
                                Text(ClientIDScreenStrings.actionButton)
                                    .font(.system(size: 28.sp, weight: .medium))
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                        }
                        .foregroundColor(Color(AppColors.white))
                        .frame(maxWidth: .infinity)
                        .frame(height: 90.h)
                        .background(Color(AppColors.primaryActionOrange))
                        .cornerRadius(12.r)
                    }
                    .disabled(isValidating)
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

    // Normalizes the input, validates the format locally, confirms it with the
    // backend, then lets the parent screen move into the existing home flow.
    private func saveClientIDAndContinue() async {
        let normalizedClientID = normalizeClientIDInput(clientID)
        clientID = normalizedClientID

        guard isValidClientID(normalizedClientID) else {
            validationErrorMessage = ClientIDScreenStrings.formatValidationMessage
            return
        }

        isValidating = true
        validationErrorMessage = nil

        do {
            let response = try await validationService.validateClientCode(normalizedClientID)
            isValidating = false

            guard response.valid else {
                validationErrorMessage = response.message ?? ClientIDScreenStrings.fallbackInvalidCodeMessage
                return
            }

            LocalUserStorage.saveClientID(normalizedClientID)
            onClientIDSaved(normalizedClientID)
        } catch {
            isValidating = false
            validationErrorMessage = error.localizedDescription
        }
    }

    // The kiosk client code is an 8-character uppercase
    private func isValidClientID(_ clientID: String) -> Bool {
        // 1. Not empty
        guard !clientID.isEmpty else { return false }

        // 2. Exactly 8 characters
        guard clientID.count == 8 else { return false }

        // 3. Only alphabets and numbers
        let pattern = "^[A-Za-z0-9]{8}$"
        return clientID.range(of: pattern, options: .regularExpression) != nil
    }

    // Keep the field aligned with the expected format by uppercasing input,
    // removing spaces, and limiting the value to 8 hexadecimal characters.
    private func normalizeClientIDInput(_ input: String) -> String {
        let uppercaseInput = input.uppercased()

        let filteredScalars = uppercaseInput.unicodeScalars.filter { scalar in
            CharacterSet.alphanumerics.contains(scalar)
        }

        return String(String.UnicodeScalarView(filteredScalars).prefix(8))
    }
}
