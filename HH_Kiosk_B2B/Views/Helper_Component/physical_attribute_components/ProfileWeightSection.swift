import SwiftUI
import UIKit

struct ProfileWeightSection: View {
    @Binding var selectedWeight: Int?  // Stored in kg
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
                tempWeight = currentWeightInput ?? selectedWeightInPounds ?? 150
                showPicker = true
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

    private var selectedWeightInPounds: Int? {
        guard let kg = selectedWeight, kg > 0 else { return nil }
        return Int(Double(kg) * 2.20462)
    }

    private func syncWeightInput() {
        if let lbs = selectedWeightInPounds {
            weightInput = String(lbs)
        } else {
            weightInput = ""
        }
    }

    private func commitWeight(_ lbs: Int) {
        weightInput = String(lbs)
        selectedWeight = Int(Double(lbs) / 2.20462)
    }
}

struct PhysicalAttributeNumberSelectionDialog: View {
    let title: String
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
                    .font(.system(size: 26.sp, weight: .bold))
                    .foregroundColor(Color(AppColors.primary))
                    .padding(.top, 36.h)

                HStack(alignment: .center, spacing: 34.w) {
                    numberRuler

                    HStack(alignment: .firstTextBaseline, spacing: 6.w) {
                        Text("\(value)")
                            .font(.system(size: 36.sp, weight: .bold))
                            .foregroundColor(Color(AppColors.black))
                        Text(unit)
                            .font(.system(size: 18.sp, weight: .regular))
                            .foregroundColor(Color(AppColors.gray))
                    }
                    .frame(width: 150.w, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 72.h)

                Spacer(minLength: 46.h)

                Button(action: onProceed) {
                    HStack(spacing: 8.w) {
                        Text("Proceed")
                            .font(.system(size: 20.sp, weight: .semibold))
                        Image(systemName: "arrow.right.circle")
                            .font(.system(size: 20.sp, weight: .semibold))
                    }
                    .foregroundColor(Color(AppColors.black))
                    .frame(maxWidth: .infinity, minHeight: 72.h)
                    .background(Color(AppColors.ctaGreen))
                    .clipShape(RoundedRectangle(cornerRadius: 10.r, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 42.w)
                .padding(.bottom, 42.h)
            }
            .frame(width: 520.w, height: 760.h)
            .background(Color(AppColors.white))
            .clipShape(RoundedRectangle(cornerRadius: 28.r, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28.r, style: .continuous)
                    .stroke(Color(AppColors.primary).opacity(0.18), lineWidth: 2.w)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 30.w, y: 12.h)
        }
    }

    private var numberRuler: some View {
        HeightRulerScrollPicker(
            selectedTotalInches: $value,
            totalInchesRange: valueRange
        )
        .frame(width: 170.w, height: 430.h)
        .background(Color(AppColors.white))
        .clipShape(RoundedRectangle(cornerRadius: 14.r, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 18.w, y: 8.h)
        .overlay(alignment: .center) {
            RoundedRectangle(cornerRadius: 2.r, style: .continuous)
                .fill(Color(AppColors.primary))
                .frame(width: 108.w, height: 4.h)
                .offset(x: 18.w)
        }
    }
}
