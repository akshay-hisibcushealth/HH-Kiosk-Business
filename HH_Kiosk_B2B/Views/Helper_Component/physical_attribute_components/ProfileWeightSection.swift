import SwiftUI
import UIKit

struct ProfileWeightSection: View {
    @Binding var selectedWeight: Int?
    @Binding var selectedWeightInPounds: Int?
    var focusedField: FocusState<PhysicalAttributesInputField?>.Binding
    @State private var weightInput: String = ""

    private let weightRange = 75...400

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

    private var selectedWeightConvertedToPounds: Int? {
        guard let kg = selectedWeight, kg > 0 else { return nil }
        return Int(Double(kg) * 2.20462)
    }

    private func syncWeightInput() {
        if let lbs = selectedWeightInPounds ?? selectedWeightConvertedToPounds {
            weightInput = String(lbs)
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

        guard let lbs = Int(digitsOnly), lbs > 0 else {
            selectedWeight = nil
            selectedWeightInPounds = nil
            return
        }

        let boundedWeight = min(lbs, weightRange.upperBound)

        if boundedWeight != lbs {
            weightInput = String(boundedWeight)
            return
        }

        selectedWeight = Int(Double(boundedWeight) / 2.20462)
        selectedWeightInPounds = boundedWeight
    }
}
