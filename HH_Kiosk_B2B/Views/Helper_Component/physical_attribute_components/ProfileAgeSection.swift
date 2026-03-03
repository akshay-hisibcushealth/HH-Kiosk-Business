import SwiftUI

struct ProfileAgeSection: View {
    @Binding var selectedAge: Int?
    @State private var ageInput: String = ""
    
    // 🔹 1. Add FocusState to control keyboard visibility
    @FocusState private var isInputActive: Bool
    
    private let ageRange = 13...75

    var body: some View {
        VStack(alignment: .leading) {
            Text("Age")
                .font(.system(size: 32.sp))


            TextField("Year", text: $ageInput)
                .font(.system(size: 36.sp))
                .focused($isInputActive)
                .textFieldStyle(.plain)
                .foregroundColor(Color(AppColors.black))
                .padding(.vertical, 30.h)
                .padding(.horizontal, 24.w)
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
                    
                    // 2. Limit to 2 digits (since max age is 75)
                    var finalValue = String(filtered.prefix(2))
                    
                    // 3. Apply Range Guard (13-75)
                    if let age = Int(finalValue) {
                        // If they've typed 2 digits and it's over 75, clear it immediately
                        if finalValue.count == 2 && age > 75 {
                            finalValue = ""
                        }
                        
                        // Update the actual binding only if it's within the valid range
                            selectedAge = age
                    
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
