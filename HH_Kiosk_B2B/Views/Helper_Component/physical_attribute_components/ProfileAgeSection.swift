import SwiftUI

struct ProfileAgeSection: View {
    @Binding var selectedAge: Int?
    @State private var ageInput: String = ""
    
    private let ageRange = 13...120

    var body: some View {
        VStack(alignment: .leading) {
            Text(PhysicalAttributesScreenStrings.Form.ageLabel)
                .font(.system(size: 24.sp, weight: .bold))
                .foregroundColor(Color(AppColors.black))

            TextField(PhysicalAttributesScreenStrings.Form.agePlaceholder, text: $ageInput)
                .font(.system(size: 28.sp, weight: .regular))
                .foregroundColor(Color(AppColors.black))
                .textContentType(.none)
                .autocorrectionDisabled()
                .padding(.vertical, 26.h)
                .padding(.horizontal, 28.w)
                .frame(maxWidth: .infinity, minHeight: 94.h)
                .background(ageInput.isEmpty ? Color(AppColors.physicalAttributeFieldBackground) : Color(AppColors.white))
                .clipShape(RoundedRectangle(cornerRadius: 12.r, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12.r)
                        .stroke(Color(AppColors.physicalAttributeFieldBorder), lineWidth: 1.5)
                )
            .onAppear {
                syncAgeInput()
            }
            .onChange(of: ageInput) { _, newValue in
                commitAgeInput(newValue)
            }
            .onChange(of: selectedAge) { _, _ in
                syncAgeInput()
            }
        }
    }

    private func syncAgeInput() {
        if let selectedAge {
            ageInput = String(selectedAge)
        } else {
            ageInput = ""
        }
    }

    private func commitAgeInput(_ input: String) {
        let digitsOnly = input.filter(\.isNumber)

        if digitsOnly != input {
            ageInput = digitsOnly
            return
        }

        guard let age = Int(digitsOnly), age > 0 else {
            selectedAge = nil
            return
        }

        let boundedAge = min(age, ageRange.upperBound)

        if boundedAge != age {
            ageInput = String(boundedAge)
            return
        }

        selectedAge = boundedAge
    }
}
