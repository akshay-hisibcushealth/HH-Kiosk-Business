import SwiftUI

struct ProfilePINSection: View {
    @Binding var pin: String
    var focusedField: Binding<PhysicalAttributesInputField?>

    var body: some View {
        VStack(alignment: .leading) {
            Text(PhysicalAttributesScreenStrings.Form.pinLabel)
                .font(.system(size: 24.sp, weight: .bold))
                .foregroundColor(Color(AppColors.black))
                .fixedSize(horizontal: false, vertical: true)

            KioskTextField(
                text: $pin,
                isFocused: PhysicalAttributesInputField.pin.focusBinding(in: focusedField),
                placeholder: PhysicalAttributesScreenStrings.Form.pinPlaceholder,
                title: PhysicalAttributesScreenStrings.Form.pinLabel,
                kind: .pin,
                onDone: { focusedField.wrappedValue = .weight }
            )
            .accessibilityLabel(PhysicalAttributesScreenStrings.Form.pinLabel)
            .frame(height: 34.h)
            .padding(.vertical, 26.h)
            .padding(.horizontal, 28.w)
            .frame(maxWidth: .infinity, minHeight: 94.h)
            .background(
                pin.isEmpty
                    ? Color(AppColors.physicalAttributeFieldBackground)
                    : Color(AppColors.white)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12.r, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12.r)
                    .stroke(Color(AppColors.physicalAttributeFieldBorder), lineWidth: 1.5)
            )
            .onChange(of: pin) { _, newValue in
                pin = String(newValue.prefix(4).filter(\.isNumber))
            }
            .onReceive(NotificationCenter.default.publisher(for: .physicalAttributesDismissInputFocus)) { _ in
                focusedField.wrappedValue = nil
                hideKeyboard()
            }
        }
        .physicalAttributeScrollTarget(.pin)
    }
}
