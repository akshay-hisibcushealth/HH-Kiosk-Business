import SwiftUI
import UIKit

struct ProfileHeightSection: View {
    @Binding var selectedHeight: Int? // Stored in cm
    var focusedField: FocusState<PhysicalAttributesInputField?>.Binding
    @State private var heightInput: String = ""

    private let heightRange = 120...250

    var body: some View {
        VStack(alignment: .leading) {
            Text(PhysicalAttributesScreenStrings.Form.heightLabel)
                .font(.system(size: 24.sp, weight: .bold))
                .foregroundColor(Color(AppColors.black))

            TextField(PhysicalAttributesScreenStrings.Form.heightPlaceholder, text: $heightInput)
                .font(.system(size: 28.sp, weight: .regular))
                .foregroundColor(Color(AppColors.black))
                .submitLabel(.done)
                .focused(focusedField, equals: .height)
                .textContentType(.none)
                .autocorrectionDisabled()
                .padding(.vertical, 26.h)
                .padding(.horizontal, 28.w)
                .frame(maxWidth: .infinity, minHeight: 94.h)
                .background(heightInput.isEmpty ? Color(AppColors.physicalAttributeFieldBackground) : Color(AppColors.white))
                .clipShape(RoundedRectangle(cornerRadius: 12.r, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12.r)
                        .stroke(Color(AppColors.physicalAttributeFieldBorder), lineWidth: 1.5)
                )
                .onAppear {
                    syncHeightInput()
                }
                .onChange(of: heightInput) { _, newValue in
                    commitHeightInput(newValue)
                }
                .onChange(of: selectedHeight) { _, _ in
                    syncHeightInput()
                }
                .onSubmit {
                    focusedField.wrappedValue = nil
                    hideKeyboard()
                }
        }
    }

    private func syncHeightInput() {
        if let cm = selectedHeight, cm > 0 {
            heightInput = String(cm)
        } else {
            heightInput = ""
        }
    }

    private func commitHeightInput(_ input: String) {
        let digitsOnly = input.filter(\.isNumber)

        if digitsOnly != input {
            heightInput = digitsOnly
            return
        }

        guard let cm = Int(digitsOnly), cm > 0 else {
            selectedHeight = nil
            return
        }

        let boundedHeight = min(cm, heightRange.upperBound)

        if boundedHeight != cm {
            heightInput = String(boundedHeight)
            return
        }

        selectedHeight = boundedHeight
    }
}
