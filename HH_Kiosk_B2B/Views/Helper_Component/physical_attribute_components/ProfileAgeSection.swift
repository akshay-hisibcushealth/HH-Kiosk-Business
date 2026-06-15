import SwiftUI
import UIKit

struct ProfileAgeSection: View {
    @Binding var selectedAge: Int?
    @State private var ageInput: String = ""
    @State private var tempAge: Int = 30
    @State private var showPicker = false
    
    private let ageRange = 13...120

    var body: some View {
        VStack(alignment: .leading) {
            Text(PhysicalAttributesScreenStrings.Form.ageLabel)
                .font(.system(size: 24.sp, weight: .bold))
                .foregroundColor(Color(AppColors.black))

            Button {
                tempAge = selectedAge ?? currentAgeInput ?? 30
                openPickerAfterDismissingKeyboard()
            } label: {
                HStack {
                    if ageInput.isEmpty {
                        Text(PhysicalAttributesScreenStrings.Form.agePlaceholder)
                            .foregroundColor(Color(AppColors.physicalAttributeFieldPlaceholder))
                    } else {
                        Text(ageInput)
                            .foregroundColor(Color(AppColors.black))
                    }
                    Spacer()
                }
                .font(.system(size: 28.sp, weight: .regular))
                .padding(.vertical, 26.h)
                .padding(.horizontal, 28.w)
                .frame(maxWidth: .infinity, minHeight: 94.h)
                .background(ageInput.isEmpty ? Color(AppColors.physicalAttributeFieldBackground) : Color(AppColors.white))
                .clipShape(RoundedRectangle(cornerRadius: 12.r, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12.r)
                        .stroke(Color(AppColors.physicalAttributeFieldBorder), lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)
            .fullScreenCover(isPresented: $showPicker) {
                PhysicalAttributeNumberSelectionDialog(
                    title: "Scroll to select your age",
                    confirmTitle: "Confirm Age",
                    value: $tempAge,
                    valueRange: Array(ageRange),
                    unit: "years",
                    onDismiss: {
                        showPicker = false
                    },
                    onProceed: {
                        commitAge(tempAge)
                        showPicker = false
                        UIDevice.current.playInputClick()
                    }
                )
                .presentationBackground(.clear)
            }
            .onAppear {
                syncAgeInput()
            }
            .onChange(of: selectedAge) { _, _ in
                syncAgeInput()
            }
        }
    }

    private var currentAgeInput: Int? {
        Int(ageInput)
    }

    private func syncAgeInput() {
        if let selectedAge {
            ageInput = String(selectedAge)
        } else {
            ageInput = ""
        }
    }

    private func commitAge(_ age: Int) {
        ageInput = String(age)
        selectedAge = age
    }

    private func openPickerAfterDismissingKeyboard() {
        NotificationCenter.default.post(name: .physicalAttributesDismissInputFocus, object: nil)
        hideKeyboard()

        DispatchQueue.main.async {
            showPicker = true
        }
    }
}
