import SwiftUI

struct ProfileWeightSection: View {
    @Binding var selectedWeight: Int?  // Stored in kg
    @Binding var selectedWeightInPounds: Int?
    @State private var weightInput: String = "" // Local input in lbs

    private let weightRange = 75...400

    var body: some View {
        VStack(alignment: .leading) {
            Text(PhysicalAttributesScreenStrings.Form.weightLabel)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(Color(AppColors.black))

            TextField(PhysicalAttributesScreenStrings.Form.weightPlaceholder, text: $weightInput)
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
                // 🔹 Input Validation Logic
                .onChange(of: weightInput) { newValue, _ in
                    // 1. Filter numeric digits only
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    
                    // 2. Limit to 3 digits
                    var finalValue = String(filtered.prefix(3))
                    
                    // 3. Apply Range Guard (75-400)
                    if let lbs = Int(finalValue), finalValue.count == 3, lbs > weightRange.upperBound {
                        finalValue = ""
                    }

                    if let lbs = Int(finalValue), weightRange.contains(lbs) {
                        selectedWeight = Int(Double(lbs) / 2.20462)
                        selectedWeightInPounds = lbs
                    } else {
                        selectedWeight = nil
                        selectedWeightInPounds = nil
                    }
                    
                    // 4. Update the text field state
                    if weightInput != finalValue {
                        weightInput = finalValue
                    }
                }
                // 🔹 Pre-fill (Kg -> Lbs)
                .onAppear {
                    if let kg = selectedWeight, kg > 0 {
                        let lbs = selectedWeightInPounds ?? Int(Double(kg) * 2.20462)
                        weightInput = String(lbs)
                    }
                }
        }
    }
}
