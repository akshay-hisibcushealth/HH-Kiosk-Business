import SwiftUI
import UIKit

struct ProfileWeightSection: View {
    @Binding var selectedWeight: Int?  // Stored in kg
    @Binding var selectedWeightInPounds: Int?
    @State private var weightInput: String = "" // Local input in lbs
    @State private var tempWeight: Int = 150
    @State private var showPicker = false

    private let weightRange = 75...400

    var body: some View {
        VStack(alignment: .leading) {
            Text(PhysicalAttributesScreenStrings.Form.weightLabel)
                .font(.system(size: 24.sp, weight: .bold))
                .foregroundColor(Color(AppColors.black))

            Button {
                tempWeight = currentWeightInput ?? selectedWeightInPounds ?? selectedWeightConvertedToPounds ?? 150
                openPickerAfterDismissingKeyboard()
            } label: {
                HStack {
                    if weightInput.isEmpty {
                        Text(PhysicalAttributesScreenStrings.Form.weightPlaceholder)
                            .foregroundColor(Color(AppColors.physicalAttributeFieldPlaceholder))
                    } else {
                        Text(weightInput)
                            .foregroundColor(Color(AppColors.black))
                    }
                    Spacer()
                }
                .font(.system(size: 28.sp, weight: .regular))
                .padding(.vertical, 26.h)
                .padding(.horizontal, 28.w)
                .frame(maxWidth: .infinity, minHeight: 94.h)
                .background(weightInput.isEmpty ? Color(AppColors.physicalAttributeFieldBackground) : Color(AppColors.white))
                .clipShape(RoundedRectangle(cornerRadius: 12.r, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12.r)
                        .stroke(Color(AppColors.physicalAttributeFieldBorder), lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)
            .fullScreenCover(isPresented: $showPicker) {
                PhysicalAttributeNumberSelectionDialog(
                    title: "Scroll to select your weight",
                    confirmTitle: "Confirm Weight",
                    value: $tempWeight,
                    valueRange: Array(weightRange),
                    unit: "lbs",
                    onDismiss: {
                        showPicker = false
                    },
                    onProceed: {
                        commitWeight(tempWeight)
                        showPicker = false
                        UIDevice.current.playInputClick()
                    }
                )
                .presentationBackground(.clear)
            }
            .onAppear {
                syncWeightInput()
            }
            .onChange(of: selectedWeight) { _, _ in
                syncWeightInput()
            }
        }
    }

    private var currentWeightInput: Int? {
        Int(weightInput)
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

    private func commitWeight(_ lbs: Int) {
        weightInput = String(lbs)
        selectedWeight = Int(Double(lbs) / 2.20462)
        selectedWeightInPounds = lbs
    }

    private func openPickerAfterDismissingKeyboard() {
        NotificationCenter.default.post(name: .physicalAttributesDismissInputFocus, object: nil)
        hideKeyboard()

        DispatchQueue.main.async {
            showPicker = true
        }
    }
}

struct PhysicalAttributeNumberSelectionDialog: View {
    let title: String
    let confirmTitle: String
    @Binding var value: Int
    let valueRange: [Int]
    let unit: String
    let onDismiss: () -> Void
    let onProceed: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.28)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 34.sp, weight: .bold))
                    .foregroundColor(Color(AppColors.black))
                    .padding(.top, 52.h)

                HStack(alignment: .center, spacing: 54.w) {
                    numberRuler

                    HStack(alignment: .firstTextBaseline, spacing: 6.w) {
                        Text("\(value)")
                            .font(.system(size: 52.sp, weight: .bold))
                            .foregroundColor(Color(AppColors.clientIDDialogBackground))
                        Text(unit)
                            .font(.system(size: 52.sp, weight: .bold))
                            .foregroundColor(Color(AppColors.clientIDDialogBackground))
                    }
                    .frame(width: 260.w, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 126.h)

                Spacer(minLength: 46.h)

                Button(action: onProceed) {
                    Text(confirmTitle)
                        .font(.system(size: 26.sp, weight: .bold))
                    .foregroundColor(Color(AppColors.black))
                    .frame(maxWidth: .infinity, minHeight: 86.h)
                    .background(Color(AppColors.ctaGreen))
                    .clipShape(RoundedRectangle(cornerRadius: 10.r, style: .continuous))
                }
                .buttonStyle(.plain)
                .frame(width: 500.w)
                .padding(.bottom, 54.h)
            }
            .frame(width: 970.w, height: 1020.h)
            .background(Color(AppColors.white))
            .clipShape(RoundedRectangle(cornerRadius: 36.r, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 36.r, style: .continuous)
                    .stroke(Color(AppColors.primary).opacity(0.18), lineWidth: 2.w)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 38.w, y: 14.h)
        }
    }

    private var numberRuler: some View {
        HeightRulerScrollPicker(
            selectedTotalInches: $value,
            totalInchesRange: valueRange,
            majorTickInterval: 5,
            minorTickInterval: nil
        )
        .frame(width: 460.w, height: 590.h)
        .background(Color(AppColors.white))
        .clipShape(RoundedRectangle(cornerRadius: 34.r, style: .continuous))
        .shadow(color: Color.black.opacity(0.16), radius: 32.w, y: 12.h)
        .overlay(alignment: .center) {
            RoundedRectangle(cornerRadius: 2.r, style: .continuous)
                .fill(Color(AppColors.primary))
                .frame(width: 300.w, height: 8.h)
                .offset(x: 62.w)
        }
    }
}
