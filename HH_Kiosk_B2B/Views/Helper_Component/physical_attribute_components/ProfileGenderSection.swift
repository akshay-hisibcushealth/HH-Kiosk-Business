
import SwiftUI

struct ProfileGenderSection: View {
    @Binding var selectedGender: String

    var body: some View {
        VStack(alignment: .leading, spacing: 22.h) {
            Text(PhysicalAttributesScreenStrings.Form.genderLabel)
                .font(.system(size: 24.sp, weight: .bold))
                .foregroundColor(Color(AppColors.black))

            HStack(spacing: 28.w) {
                ForEach(PhysicalAttributesScreenStrings.Form.genderOptions, id: \.self) { gender in
                    genderButton(gender)
                }
            }
        }
    }

    private func genderButton(_ gender: String) -> some View {
        let isSelected = selectedGender == gender

        return Button {
            selectedGender = gender
            HapticFeedback.light()
        } label: {
            HStack(spacing: 18.w) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32.sp, weight: .bold))
                        .foregroundColor(Color(AppColors.white))
                }

                Text(gender)
                    .font(.system(size: 28.sp, weight: .bold))
                    .foregroundColor(isSelected ? Color(AppColors.white) : Color(AppColors.physicalAttributeText))
            }
            .frame(maxWidth: .infinity, minHeight: 90.h)
            .background(isSelected ? Color(AppColors.primary) : Color(AppColors.physicalAttributeFieldBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14.r, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14.r, style: .continuous)
                    .stroke(isSelected ? Color(AppColors.clientIDDialogBackground) : Color(AppColors.physicalAttributeFieldBorder), lineWidth: isSelected ? 2 : 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
