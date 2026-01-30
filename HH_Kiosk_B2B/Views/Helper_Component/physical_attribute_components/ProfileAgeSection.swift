import SwiftUI

struct ProfileAgeSection: View {
    @Binding var selectedAge: Int?
    @State private var ageInput: String = ""
    
    // 🔹 1. Add FocusState to control keyboard visibility
    @FocusState private var isInputActive: Bool
    
    private let ageRange = 13...75

    var body: some View {
        VStack(alignment: .leading) {
            Text("Age (years)")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.black)

            TextField("Select age", text: $ageInput)
                .keyboardType(.asciiCapableNumberPad)

                .focused($isInputActive) // 🔹 2. Bind the text field to the focus state
                .textFieldStyle(.plain)
                .foregroundColor(.black)
                .padding(.vertical, 20.h)
                .padding(.horizontal, 16.w)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .keyboardType(.asciiCapableNumberPad)
                .overlay(
                    RoundedRectangle(cornerRadius: 12.r)
                        .stroke(Color.black, lineWidth: 1)
                )
                // Logic to filter input and handle range
                .onChange(of: ageInput) { newValue, _ in
                    // 1. Filter numeric digits only
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    
                    // 2. Limit to 2 digits (since max age is 75)
                    var finalValue = String(filtered.prefix(2))
                    
                    // 3. Apply Range Guard (13-75)
                    if let age = Int(finalValue) {
                        // If they've typed 2 digits and it's over 75, clear it immediately
                        if finalValue.count == 2 && age > 75 {
                            finalValue = ""
                        }
                        
                        // Update the actual binding only if it's within the valid range
                        if ageRange.contains(age) {
                            selectedAge = age
                        } else {
                            selectedAge = nil
                        }
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
