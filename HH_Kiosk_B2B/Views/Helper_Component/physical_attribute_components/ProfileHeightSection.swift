import SwiftUI
import UIKit

struct ProfileHeightSection: View {
    @Binding var selectedHeight: Int?
    @Binding var selectedHeightForBackend: Int?
    var focusedField: FocusState<PhysicalAttributesInputField?>.Binding

    @State private var committedFeet: Int? = nil
    @State private var committedInches: Int? = nil
    @State private var tempFeet: Int = 5
    @State private var tempInches: Int = 6
    @State private var showPicker: Bool = false

    private let feetRange = Array(4...7)
    private let inchRange = Array(0...11)

    var body: some View {
        VStack(alignment: .leading) {
            Text(PhysicalAttributesScreenStrings.Form.heightLabel)
                .font(.system(size: 24.sp, weight: .bold))
                .foregroundColor(Color(AppColors.black))

            Button {
                preparePickerValues()
                openPickerAfterDismissingKeyboard()
            } label: {
                HStack {
                    if let feet = committedFeet, let inches = committedInches {
                        Text("\(feet) \(PhysicalAttributesScreenStrings.Form.feetUnit) \(inches) \(PhysicalAttributesScreenStrings.Form.inchesUnit)")
                            .foregroundColor(Color(AppColors.black))
                    } else {
                        Text(PhysicalAttributesScreenStrings.Form.heightPlaceholder)
                            .foregroundColor(Color(AppColors.physicalAttributeFieldPlaceholder))
                    }

                    Spacer()
                }
                .font(.system(size: 28.sp, weight: .regular))
                .padding(.vertical, 26.h)
                .padding(.horizontal, 28.w)
                .frame(maxWidth: .infinity, minHeight: 94.h)
                .background(heightFieldBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12.r, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12.r)
                        .stroke(Color(AppColors.physicalAttributeFieldBorder), lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showPicker) {
                VStack(spacing: 24.h) {
                    Text(PhysicalAttributesScreenStrings.Form.heightSheetTitle)
                        .font(.system(size: 64.sp, weight: .bold))
                        .foregroundColor(Color(AppColors.black))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    HStack(spacing: 32.w) {
                        WheelSelector(
                            items: feetRange,
                            selection: $tempFeet,
                            label: PhysicalAttributesScreenStrings.Form.feetUnit
                        )

                        WheelSelector(
                            items: inchRange,
                            selection: $tempInches,
                            label: PhysicalAttributesScreenStrings.Form.inchesUnit
                        )
                    }

                    Button {
                        commitHeight()
                    } label: {
                        Text(PhysicalAttributesScreenStrings.Form.confirmButton)
                            .font(.system(size: 56.sp, weight: .heavy))
                            .foregroundColor(Color(red: 0.0, green: 0.42, blue: 0.18))
                            .frame(minHeight: 88.h)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 40.h)
                .padding(.bottom, 40.h)
                .padding(.horizontal, 40.w)
                .frame(width: 720.w, height: 680.h)
                .background(Color(AppColors.white))
                .presentationBackground(Color(AppColors.white))
            }
        }
        .onAppear {
            syncCommittedHeight()
        }
        .onChange(of: selectedHeight) { _, _ in
            syncCommittedHeight()
        }
        .onReceive(NotificationCenter.default.publisher(for: .physicalAttributesDismissInputFocus)) { _ in
            showPicker = false
        }
    }

    private func preparePickerValues() {
        if let feet = committedFeet, let inches = committedInches {
            tempFeet = feet
            tempInches = inches
        } else if let cm = selectedHeight {
            let totalInches = Int(round(Double(cm) / 2.54))
            tempFeet = totalInches / 12
            tempInches = totalInches % 12
        } else {
            tempFeet = 5
            tempInches = 6
        }
    }

    private func openPickerAfterDismissingKeyboard() {
        focusedField.wrappedValue = nil
        NotificationCenter.default.post(name: .physicalAttributesDismissInputFocus, object: nil)
        hideKeyboard()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            showPicker = true
        }
    }

    private func commitHeight() {
        committedFeet = tempFeet
        committedInches = tempInches

        let totalInches = tempFeet * 12 + tempInches
        selectedHeight = Int(Double(totalInches) * 2.54)
        selectedHeightForBackend = Self.backendHeightInCentimeters(feet: tempFeet, inches: tempInches)

        showPicker = false
        UIDevice.current.playInputClick()
    }

    private func syncCommittedHeight() {
        guard let cm = selectedHeight else {
            committedFeet = nil
            committedInches = nil
            return
        }

        let totalInches = Int(round(Double(cm) / 2.54))
        committedFeet = totalInches / 12
        committedInches = totalInches % 12
    }

    private var heightFieldBackground: Color {
        committedFeet == nil || committedInches == nil
            ? Color(AppColors.physicalAttributeFieldBackground)
            : Color(AppColors.white)
    }

    private static func backendHeightInCentimeters(feet: Int, inches: Int) -> Int {
        let totalInches = Double((feet * 12) + inches)
        return Int(totalInches * 2.53986)
    }
}

struct WheelSelector<T: Hashable & CustomStringConvertible>: View {
    let items: [T]
    @Binding var selection: T
    let label: String

    var body: some View {
        VStack {
            Text(label)
                .font(.system(size: 48.sp))
                .foregroundColor(Color(AppColors.gray))

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 20.h) {
                        ForEach(items, id: \.self) { item in
                            Text(item.description)
                                .font(.system(size: selection == item ? 64.sp : 56.sp))
                                .frame(maxWidth: .infinity)
                                .frame(height: 80.h)
                                .background(selection == item ? Color(AppColors.gray).opacity(0.2) : Color.clear)
                                .cornerRadius(16.r)
                                .id(item)
                                .onTapGesture {
                                    withAnimation {
                                        selection = item
                                    }

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                                        withAnimation {
                                            proxy.scrollTo(item, anchor: .center)
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 16.h)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                            proxy.scrollTo(selection, anchor: .center)
                        }
                    }
                    .onChange(of: selection) { _, newValue in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                            withAnimation {
                                proxy.scrollTo(newValue, anchor: .center)
                            }
                        }
                    }
                }
                .frame(height: 320.h)
            }
            .frame(width: 200.w)
        }
    }
}
