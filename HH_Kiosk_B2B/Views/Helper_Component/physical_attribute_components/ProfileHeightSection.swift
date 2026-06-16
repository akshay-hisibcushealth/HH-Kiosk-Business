import SwiftUI
import UIKit

struct ProfileHeightSection: View {
    @Binding var selectedHeight: Int?

    // COMMITTED (shown in text field)
    @State private var committedFeet: Int? = nil
    @State private var committedInches: Int? = nil

    // TEMP (used inside picker only)
    @State private var tempFeet: Int = 5
    @State private var tempInches: Int = 6

    @State private var showPicker: Bool = false

    let feetRange = Array(4...7)
    let inchRange = Array(0...11)

    var body: some View {
        VStack(alignment: .leading) {
            Text(PhysicalAttributesScreenStrings.Form.heightLabel)
                .font(.system(size: 24.sp, weight: .bold))
                .foregroundColor(Color(AppColors.black))

            Button {
                // Initialize temp values when opening picker
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
            .fullScreenCover(isPresented: $showPicker) {
                HeightSelectionDialog(
                    tempFeet: $tempFeet,
                    tempInches: $tempInches,
                    feetRange: feetRange,
                    inchRange: inchRange,
                    onDismiss: {
                        showPicker = false
                    },
                    onProceed: {
                        // ✅ COMMIT ONLY HERE
                        committedFeet = tempFeet
                        committedInches = tempInches

                        let totalInches = tempFeet * 12 + tempInches
                        selectedHeight = Int(Double(totalInches) * 2.54)

                        showPicker = false
                        UIDevice.current.playInputClick()
                    }
                )
                .presentationBackground(.clear)
            }
        }
        .onAppear {
            syncCommittedHeight()
        }
        .onChange(of: selectedHeight) { _, _ in
            syncCommittedHeight()
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

    private func openPickerAfterDismissingKeyboard() {
        NotificationCenter.default.post(name: .physicalAttributesDismissInputFocus, object: nil)
        hideKeyboard()

        DispatchQueue.main.async {
            showPicker = true
        }
    }
}

private struct HeightSelectionDialog: View {
    @Binding var tempFeet: Int
    @Binding var tempInches: Int

    let feetRange: [Int]
    let inchRange: [Int]
    let onDismiss: () -> Void
    let onProceed: () -> Void

    private var selectedTotalInches: Int {
        tempFeet * 12 + tempInches
    }

    private var totalInchesRange: [Int] {
        guard let minFeet = feetRange.min(), let maxFeet = feetRange.max() else {
            return []
        }

        return Array((minFeet * 12)...((maxFeet * 12) + 11))
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.28)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: 0) {
                Text("Scroll to select your height")
                    .font(.system(size: 34.sp, weight: .bold))
                    .foregroundColor(Color(AppColors.black))
                    .padding(.top, 52.h)

                HStack(alignment: .center, spacing: 54.w) {
                    heightRuler

                    Text("\(tempFeet) ft \(tempInches) in")
                        .font(.system(size: 52.sp, weight: .bold))
                        .foregroundColor(Color(AppColors.clientIDDialogBackground))
                        .frame(width: 250.w, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 126.h)

                Spacer(minLength: 46.h)

                Button(action: onProceed) {
                    Text("Confirm Height")
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

    private var heightRuler: some View {
        HeightRulerScrollPicker(
            selectedTotalInches: Binding(
                get: { selectedTotalInches },
                set: { totalInches in
                    tempFeet = totalInches / 12
                    tempInches = totalInches % 12
                }
            ),
            totalInchesRange: totalInchesRange
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

struct HeightRulerScrollPicker: UIViewRepresentable {
    @Binding var selectedTotalInches: Int

    let totalInchesRange: [Int]
    var majorTickInterval: Int = 12
    var minorTickInterval: Int? = 6

    func makeUIView(context: Context) -> SnappingHeightRulerView {
        let view = SnappingHeightRulerView()
        view.onSelectionSettled = { selectedTotalInches = $0 }
        return view
    }

    func updateUIView(_ uiView: SnappingHeightRulerView, context: Context) {
        uiView.configure(
            totalInchesRange: totalInchesRange,
            selectedTotalInches: selectedTotalInches,
            rowHeight: 18.h,
            selectedColor: AppColors.primary,
            nearbyColor: AppColors.ctaGreen,
            mutedColor: AppColors.gray,
            majorTickInterval: majorTickInterval,
            minorTickInterval: minorTickInterval
        )
    }
}

final class SnappingHeightRulerView: UIView, UIScrollViewDelegate {
    var onSelectionSettled: ((Int) -> Void)?

    private let scrollView = UIScrollView()
    private let rulerContentView = HeightRulerContentView()
    private var totalInchesRange: [Int] = []
    private var selectedTotalInches = 0
    private var rowHeight: CGFloat = 12
    private var majorTickInterval = 12
    private var minorTickInterval: Int? = 6
    private var didInitialScroll = false
    private var isApplyingSelection = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        updateContentSize()

        if !didInitialScroll {
            didInitialScroll = true
            scrollToSelected(animated: false)
        }
    }

    func configure(
        totalInchesRange: [Int],
        selectedTotalInches: Int,
        rowHeight: CGFloat,
        selectedColor: UIColor,
        nearbyColor: UIColor,
        mutedColor: UIColor,
        majorTickInterval: Int,
        minorTickInterval: Int?
    ) {
        let previousSelected = self.selectedTotalInches
        let rangeChanged = self.totalInchesRange != totalInchesRange

        self.totalInchesRange = totalInchesRange
        self.selectedTotalInches = selectedTotalInches
        self.rowHeight = rowHeight
        self.majorTickInterval = majorTickInterval
        self.minorTickInterval = minorTickInterval

        rulerContentView.configure(
            totalInchesRange: totalInchesRange,
            selectedTotalInches: selectedTotalInches,
            rowHeight: rowHeight,
            selectedColor: selectedColor,
            nearbyColor: nearbyColor,
            mutedColor: mutedColor,
            majorTickInterval: majorTickInterval,
            minorTickInterval: minorTickInterval
        )

        updateContentSize()

        if rangeChanged {
            didInitialScroll = false
        } else if previousSelected != selectedTotalInches && !isApplyingSelection {
            scrollToSelected(animated: true)
        }
    }

    private func setup() {
        backgroundColor = .clear
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.decelerationRate = .fast
        scrollView.delegate = self
        scrollView.addSubview(rulerContentView)
        addSubview(scrollView)
    }

    private func updateContentSize() {
        guard !totalInchesRange.isEmpty else { return }

        let contentHeight = CGFloat(max(totalInchesRange.count - 1, 0)) * rowHeight
        rulerContentView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: contentHeight)
        scrollView.contentSize = CGSize(width: bounds.width, height: contentHeight)
        let inset = max(bounds.height / 2, 0)
        scrollView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
    }

    private func scrollToSelected(animated: Bool) {
        guard let index = totalInchesRange.firstIndex(of: selectedTotalInches) else { return }

        let targetY = (CGFloat(index) * rowHeight) - scrollView.contentInset.top
        scrollView.setContentOffset(CGPoint(x: 0, y: targetY), animated: animated)
    }

    private func snappedOffsetY(for proposedOffsetY: CGFloat) -> CGFloat {
        guard !totalInchesRange.isEmpty else { return proposedOffsetY }

        let rawIndex = (proposedOffsetY + scrollView.contentInset.top) / rowHeight
        let snappedIndex = min(max(Int(round(rawIndex)), 0), totalInchesRange.count - 1)
        return (CGFloat(snappedIndex) * rowHeight) - scrollView.contentInset.top
    }

    private func settleSelection() {
        guard !totalInchesRange.isEmpty else { return }

        let snappedY = snappedOffsetY(for: scrollView.contentOffset.y)
        if abs(scrollView.contentOffset.y - snappedY) > 0.5 {
            scrollView.setContentOffset(CGPoint(x: 0, y: snappedY), animated: true)
        }

        let index = min(max(Int(round((snappedY + scrollView.contentInset.top) / rowHeight)), 0), totalInchesRange.count - 1)
        let totalInches = totalInchesRange[index]
        selectedTotalInches = totalInches
        rulerContentView.selectedTotalInches = totalInches

        isApplyingSelection = true
        onSelectionSettled?(totalInches)
        isApplyingSelection = false
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        targetContentOffset.pointee.y = snappedOffsetY(for: targetContentOffset.pointee.y)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            settleSelection()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        settleSelection()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        settleSelection()
    }
}

final class HeightRulerContentView: UIView {
    var totalInchesRange: [Int] = []
    var selectedTotalInches: Int = 0 {
        didSet { setNeedsDisplay() }
    }
    var rowHeight: CGFloat = 12
    var selectedColor: UIColor = AppColors.primary
    var nearbyColor: UIColor = AppColors.ctaGreen
    var mutedColor: UIColor = AppColors.gray
    var majorTickInterval = 12
    var minorTickInterval: Int? = 6

    func configure(
        totalInchesRange: [Int],
        selectedTotalInches: Int,
        rowHeight: CGFloat,
        selectedColor: UIColor,
        nearbyColor: UIColor,
        mutedColor: UIColor,
        majorTickInterval: Int,
        minorTickInterval: Int?
    ) {
        self.totalInchesRange = totalInchesRange
        self.selectedTotalInches = selectedTotalInches
        self.rowHeight = rowHeight
        self.selectedColor = selectedColor
        self.nearbyColor = nearbyColor
        self.mutedColor = mutedColor
        self.majorTickInterval = majorTickInterval
        self.minorTickInterval = minorTickInterval
        backgroundColor = .clear
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setLineCap(.round)

        for (index, totalInches) in totalInchesRange.enumerated() {
            let y = CGFloat(index) * rowHeight
            let isSelected = totalInches == selectedTotalInches
            let isNearby = abs(totalInches - selectedTotalInches) <= 8
            let isMajorTick = majorTickInterval > 0 && totalInches % majorTickInterval == 0
            let isMinorTick = minorTickInterval.map { $0 > 0 && totalInches % $0 == 0 } ?? false
            let tickWidth: CGFloat = {
                if isSelected || isMajorTick { return 96.w }
                if isMinorTick { return 72.w }
                return 38.w
            }()

            let color = isNearby ? nearbyColor : mutedColor.withAlphaComponent(0.22)
            context.setStrokeColor((isSelected ? selectedColor : color).cgColor)
            context.setLineWidth(isSelected ? 4.h : 2.h)
            context.move(to: CGPoint(x: bounds.maxX - tickWidth - 18.w, y: y))
            context.addLine(to: CGPoint(x: bounds.maxX - 18.w, y: y))
            context.strokePath()
        }
    }
}

struct WheelSelector<T: Hashable & CustomStringConvertible>: View {
    let items: [T]
    @Binding var selection: T
    let label: String

    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(Color(AppColors.gray))

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(items, id: \.self) { item in
                            Text(item.description)
                                .font(selection == item ? .headline : .body)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40.h)
                                .background(selection == item ? Color(AppColors.gray).opacity(0.2) : Color(AppColors.clear))
                                .cornerRadius(8.r)
                                .id(item) // important: solid id for scrollTo
                                .onTapGesture {
                                    withAnimation {
                                        selection = item
                                    }
                                    // ensure we scroll to the tapped item (after state update/layout)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                                        withAnimation {
                                            proxy.scrollTo(item, anchor: .center)
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 8)
                    .onAppear {
                        // scroll once after the view has appeared and laid out
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                            proxy.scrollTo(selection, anchor: .center)
                        }
                    }
                    .onChange(of: selection) { _,newVal in
                        // when selection changes (only for this wheel), scroll to it
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                            withAnimation {
                                proxy.scrollTo(newVal, anchor: .center)
                            }
                        }
                    }
                }
                .frame(height: 160.h)
            }
            .frame(width: 100.w)
        }
    }
}
