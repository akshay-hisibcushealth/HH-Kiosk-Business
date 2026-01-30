import SwiftUI

struct ProfileWeightSection: View {
    @Binding var selectedWeight: Int?  // Stored in kg
    @State private var weightInput: String = "" // Local input in lbs

    private let weightRange = 75...400

    var body: some View {
        VStack(alignment: .leading) {
            Text("Weight (lbs)")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.black)

            TextField("Select weight", text: $weightInput)
                // 🔹 FIX: Use .numbersAndPunctuation to force full-width keyboard on iPad
                // (.numberPad forces the small floating window on iPadOS)
                .keyboardType(.asciiCapableNumberPad)
                .textFieldStyle(.plain)
                .foregroundColor(.black)
                .padding(.vertical, 20.h)
                .padding(.horizontal, 16.w)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12.r)
                        .stroke(Color.black, lineWidth: 1)
                )
                // 🔹 Input Validation Logic
                .onChange(of: weightInput) { newValue, _ in
                    // 1. Filter numeric digits only
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    
                    // 2. Limit to 3 digits
                    var finalValue = String(filtered.prefix(3))
                    
                    // 3. Apply Range Guard (75-400)
                    if let lbs = Int(finalValue) {
                        // If they've typed 3 digits and it's over 400, clear it
                        if finalValue.count == 3 && lbs > 400 {
                            finalValue = ""
                        }
                        
                        // Sync with the actual weight binding
                        if weightRange.contains(lbs) {
                            selectedWeight = Int(Double(lbs) / 2.20462)
                        } else {
                            selectedWeight = nil
                        }
                    }
                    
                    // 4. Update the text field state
                    if weightInput != finalValue {
                        weightInput = finalValue
                    }
                }
                // 🔹 Pre-fill (Kg -> Lbs)
                .onAppear {
                    if let kg = selectedWeight, kg > 0 {
                        let lbs = Int(Double(kg) * 2.20462)
                        weightInput = String(lbs)
                    }
                }
        }
    }
}
