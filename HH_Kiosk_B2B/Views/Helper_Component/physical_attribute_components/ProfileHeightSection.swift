import SwiftUI
import UIKit

struct ProfileHeightSection: View {
    @Binding var selectedHeight: Int?
    var focusedField: Binding<PhysicalAttributesInputField?>
    @Binding var showPicker: Bool

    @State private var committedFeet: Int? = nil
    @State private var committedInches: Int? = nil

    var body: some View {
        VStack(alignment: .leading) {
            Text(PhysicalAttributesScreenStrings.Form.heightLabel)
                .font(.system(size: 24.sp, weight: .bold))
                .foregroundColor(Color(AppColors.black))

            Button {
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
        }
        .onAppear {
            syncCommittedHeight()
        }
        .onChange(of: focusedField.wrappedValue) { _, field in
            if field == .height {
                openPickerAfterDismissingKeyboard()
            }
        }
        .onChange(of: selectedHeight) { _, _ in
            syncCommittedHeight()
        }
        .onReceive(NotificationCenter.default.publisher(for: .physicalAttributesDismissInputFocus)) { _ in
            showPicker = false
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
}

struct HeightPickerPresentation: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var selectedHeight: Int?
    var focusedField: Binding<PhysicalAttributesInputField?>
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var animation: Animation { .easeInOut(duration: 0.22) }

    func body(content: Content) -> some View {
        content
            .blur(radius: isPresented ? 8 : 0)
            .allowsHitTesting(!isPresented)
            .accessibilityHidden(isPresented)
            .overlay {
                GeometryReader { geometry in
                    ZStack {
                        if isPresented {
                            Button { dismiss() } label: {
                                Color.black.opacity(0.18)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Cancel height selection")
                            .transition(.opacity)

                            HeightPickerPopup(selectedHeight: selectedHeight) { height in
                                selectedHeight = height
                                dismiss(focusAge: true)
                                UIDevice.current.playInputClick()
                            }
                            .frame(width: min(720.w, geometry.size.width - 32),
                                   height: min(680.h, geometry.size.height - 32))
                            .background(Color(AppColors.white))
                            .clipShape(RoundedRectangle(cornerRadius: 28.r, style: .continuous))
                            .shadow(color: .black.opacity(0.16), radius: 24, y: 8)
                            .accessibilityAddTraits(.isModal)
                            .accessibilityAction(.escape) { dismiss() }
                            .transition(.opacity.combined(with: .scale(scale: reduceMotion ? 1 : 0.96)))
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .ignoresSafeArea()
            }
            // One transaction keeps the popup, dimming, and blur in sync.
            .animation(animation, value: isPresented)
    }

    private func dismiss(focusAge: Bool = false) {
        guard isPresented else { return }
        withAnimation(animation, completionCriteria: .removed) {
            isPresented = false
        } completion: {
            // Opening the keyboard during dismissal makes the backdrop jump.
            if focusAge, !isPresented, focusedField.wrappedValue == nil {
                focusedField.wrappedValue = .age
            }
        }
    }
}

private struct HeightPickerPopup: View {
    @State private var tempFeet: Int
    @State private var tempInches: Int
    let onConfirm: (Int) -> Void

    init(selectedHeight: Int?, onConfirm: @escaping (Int) -> Void) {
        let totalInches = selectedHeight.map { Int(round(Double($0) / 2.54)) } ?? 66
        _tempFeet = State(initialValue: totalInches / 12)
        _tempInches = State(initialValue: totalInches % 12)
        self.onConfirm = onConfirm
    }

    var body: some View {
        VStack(spacing: 24.h) {
            Text(PhysicalAttributesScreenStrings.Form.heightSheetTitle)
                .font(.system(size: 64.sp, weight: .bold))
                .foregroundColor(Color(AppColors.black))
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            HStack(spacing: 32.w) {
                WheelSelector(
                    items: Array(4...7),
                    selection: $tempFeet,
                    label: PhysicalAttributesScreenStrings.Form.feetUnit
                )

                WheelSelector(
                    items: Array(0...11),
                    selection: $tempInches,
                    label: PhysicalAttributesScreenStrings.Form.inchesUnit
                )
            }

            Button {
                onConfirm(Int(Double(tempFeet * 12 + tempInches) * 2.54))
            } label: {
                Text("CONFIRM")
                    .font(.system(size: 44.sp, weight: .semibold))
                    .foregroundColor(Color(AppColors.black))
                    .frame(maxWidth: .infinity, minHeight: 104.h)
                    .background(Color(AppColors.ctaGreen))
                    .clipShape(RoundedRectangle(cornerRadius: 10.r, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 64.w)
        }
        .padding(.vertical, 40.h)
        .padding(.horizontal, 40.w)
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
