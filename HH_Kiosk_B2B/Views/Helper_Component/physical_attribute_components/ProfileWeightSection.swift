import SwiftUI
import UIKit

struct ProfileWeightSection: View {
    @Binding var selectedWeight: Int?  // Stored in kg
    @Binding var selectedWeightInPounds: Int?
    var focusedField: FocusState<PhysicalAttributesInputField?>.Binding
    @State private var weightInput: String = "" // Local input in kg
    
    private let weightRange = 34...181
    private let poundsPerKilogram = 2.20462

    var body: some View {
        VStack(alignment: .leading) {
            Text(PhysicalAttributesScreenStrings.Form.weightLabel)
                .font(.system(size: 24.sp, weight: .bold))
                .foregroundColor(Color(AppColors.black))

            TextField(PhysicalAttributesScreenStrings.Form.weightPlaceholder, text: $weightInput)
                .font(.system(size: 28.sp, weight: .regular))
                .foregroundColor(Color(AppColors.black))
                .submitLabel(.done)
                .focused(focusedField, equals: .weight)
                .textContentType(.none)
                .autocorrectionDisabled()
                .padding(.vertical, 26.h)
                .padding(.horizontal, 28.w)
                .frame(maxWidth: .infinity, minHeight: 94.h)
                .background(weightInput.isEmpty ? Color(AppColors.physicalAttributeFieldBackground) : Color(AppColors.white))
                .clipShape(RoundedRectangle(cornerRadius: 12.r, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12.r)
                        .stroke(Color(AppColors.physicalAttributeFieldBorder), lineWidth: 1.5)
                )
            .onAppear {
                syncWeightInput()
            }
            .onChange(of: weightInput) { _, newValue in
                commitWeightInput(newValue)
            }
            .onChange(of: selectedWeight) { _, _ in
                syncWeightInput()
            }
            .onSubmit {
                focusedField.wrappedValue = nil
                hideKeyboard()
            }
        }
    }

    private var selectedWeightInPoundsConvertedToKilograms: Int? {
        guard let lbs = selectedWeightInPounds, lbs > 0 else { return nil }
        return Int((Double(lbs) / poundsPerKilogram).rounded())
    }

    private func syncWeightInput() {
        if let kg = selectedWeight ?? selectedWeightInPoundsConvertedToKilograms {
            weightInput = String(kg)
        } else {
            weightInput = ""
        }
    }

    private func commitWeightInput(_ input: String) {
        let digitsOnly = input.filter(\.isNumber)

        if digitsOnly != input {
            weightInput = digitsOnly
            return
        }

        guard let kg = Int(digitsOnly), kg > 0 else {
            selectedWeight = nil
            selectedWeightInPounds = nil
            return
        }

        let boundedWeight = min(kg, weightRange.upperBound)

        if boundedWeight != kg {
            weightInput = String(boundedWeight)
            return
        }

        selectedWeight = boundedWeight
        selectedWeightInPounds = Int((Double(boundedWeight) * poundsPerKilogram).rounded())
    }
}
