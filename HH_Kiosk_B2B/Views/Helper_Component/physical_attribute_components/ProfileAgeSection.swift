import SwiftUI

struct ProfileAgeSection: View {
    @Binding var selectedAge: Int?
    @State private var ageInput: String = ""
    
    // 🔹 1. Add FocusState to control keyboard visibility
    @FocusState private var isInputActive: Bool
    
    private let ageRange = 13...120

    var body: some View {
        VStack(alignment: .leading) {
            Text(PhysicalAttributesScreenStrings.Form.ageLabel)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(Color(AppColors.black))

            TextField(PhysicalAttributesScreenStrings.Form.agePlaceholder, text: $ageInput)
                .focused($isInputActive) // 🔹 2. Bind the text field to the focus state
                .textFieldStyle(.plain)
                .foregroundColor(Color(AppColors.black))
                .padding(.vertical, 20.h)
                .padding(.horizontal, 16.w)
                .frame(maxWidth: .infinity)
                .background(Color(AppColors.white))
                .overlay(
                    RoundedRectangle(cornerRadius: 12.r)
                        .stroke(Color(AppColors.black), lineWidth: 1)
                )
                // Logic to filter input and handle range
                .onChange(of: ageInput) { newValue, _ in
                    // 1. Filter numeric digits only
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    
                    // 2. Limit to 3 digits (since max age is 120)
                    var finalValue = String(filtered.prefix(3))
                    
                    // 3. Apply range guard (13-120)
                    if let age = Int(finalValue) {
                        // If the value exceeds the supported range, clear it immediately.
                        if age > ageRange.upperBound {
                            finalValue = ""
                        }
                        
                        selectedAge = Int(finalValue)
                    
                    } else {
                        selectedAge = nil // Clear binding if field is empty
                    }
                    
                    // 4. Update the text field state to stay in sync
                    if ageInput != finalValue {
                        ageInput = finalValue
                    }
                }
                .onAppear {
                    if let age = selectedAge {
                        ageInput = String(age)
                    }
                }
        }
    }
}
