import SwiftUI

enum ScanProgressStep: Int, CaseIterable, Identifiable {
    case faceScan = 1
    case report
    case nextSteps

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .faceScan: return "Face Scan"
        case .report: return "Report"
        case .nextSteps: return "Next Steps"
        }
    }
}

/// A status indicator, rather than navigation: users advance through the screen actions.
struct ScanProgressView: View {
    let currentStep: ScanProgressStep

    var body: some View {
        GeometryReader { geometry in
            // Use the available width so rotation and resized windows both lay out correctly.
            let scale = min(max(geometry.size.width / 1192, 0.65), 1)

            HStack(spacing: 0) {
                ForEach(ScanProgressStep.allCases) { step in
                    stepItem(step, scale: scale)
                }
            }
            .padding(.horizontal, 20 * scale)
        }
        .frame(height: 72)
        .background(Color(AppColors.white))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(currentStep.rawValue) of \(ScanProgressStep.allCases.count): \(currentStep.title)")
    }

    private func stepItem(_ step: ScanProgressStep, scale: CGFloat) -> some View {
        let isActive = step == currentStep

        return VStack(spacing: 0) {
            HStack(spacing: 16 * scale) {
                Text("\(step.rawValue)")
                    .font(.system(size: 22 * scale, weight: .bold))
                    .foregroundStyle(Color(AppColors.white))
                    .frame(width: 28 * scale, height: 28 * scale)
                    .background(isActive ? Color(AppColors.primary) : Color(AppColors.scanProgressInactiveBadge))
                    .clipShape(Circle())

                Text(step.title)
                    .font(.system(size: 24 * scale, weight: .bold))
                    .foregroundStyle(isActive ? Color(AppColors.black) : Color(AppColors.scanProgressInactiveText))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(.horizontal, 8 * scale)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Rectangle()
                .fill(isActive ? Color(AppColors.scanProgressActiveTrack) : Color(AppColors.scanProgressInactiveTrack))
                .frame(height: 6)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Portrait steps", traits: .fixedLayout(width: 768, height: 280)) {
    VStack(spacing: 20) {
        ForEach(ScanProgressStep.allCases) { step in
            ScanProgressView(currentStep: step)
        }
    }
}

#Preview("Landscape steps", traits: .fixedLayout(width: 1194, height: 280)) {
    VStack(spacing: 20) {
        ForEach(ScanProgressStep.allCases) { step in
            ScanProgressView(currentStep: step)
        }
    }
}
