import SwiftUI

// ----------------------
// Tagged interpretation JSON
// ----------------------
let interpretationJSON = ResultScreenStrings.Metrics.interpretations

// ----------------------
// UI: ResultsList & ResultRow
// ----------------------
struct ResultsList: View {
    @ObservedObject var model: ResultsModel

    var body: some View {
        LazyVStack(spacing: 22.h) {
            ForEach(model.resultsArray, id: \.key) { pair in
                ResultRow(
                    metricKey: pair.key,
                    title: displayTitle(for: pair.key),
                    subtitle: descriptionText(for: pair.key),
                    value: pair.value.value
                )
            }
        }
        .padding(.horizontal, 34.w)
        .padding(.top, 8.h)
        .padding(.bottom, 30.h)
    }
}

struct ResultRow: View {
    let metricKey: String
    let title: String
    let subtitle: String
    let value: Double

    private var message: String {
        getTaggedMessage(metricKey: metricKey, value: value)
    }

    private var indicatorColor: Color {
        meterBandColor(for: metricKey, value: value, colors: gaugeColors)
    }

    private var riskLabel: String {
        displayRiskLabel(for: metricKey, value: value)
    }

    private var showsMeterValue: Bool {
        ![
            "HBA1C_RISK_PROB",
            "HDLTC_RISK_PROB",
            "TG_RISK_PROB",
            "BP_CVD"
        ].contains(metricKey)
    }

    // Match the reference result screen's metric-specific band patterns.
    private var gaugeColors: [Color] {
        switch metricKey {
        case "BP_SYSTOLIC", "BP_DIASTOLIC":
            return [
                Color(AppColors.dialBandYellow),
                Color(AppColors.dialBandGreen),
                Color(AppColors.dialBandLightGreen),
                Color(AppColors.dialBandYellow),
                Color(AppColors.dialBandRed)
            ]

        case "HR_BPM":
            return [
                Color(AppColors.dialBandYellow),
                Color(AppColors.dialBandGreen),
                Color(AppColors.dialBandYellow)
            ]

        default:
            return [
                Color(AppColors.dialBandGreen),
                Color(AppColors.dialBandLightGreen),
                Color(AppColors.dialBandYellow),
                Color(AppColors.dialBandLightRed),
                Color(AppColors.dialBandRed)
            ]
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 36.sp, weight: .bold))
                .foregroundColor(Color(AppColors.black))

            Text(subtitle)
                .font(.system(size: 28.sp, weight: .regular))
                .foregroundColor(Color(AppColors.bodyText))
                .lineSpacing(8.h)
                .multilineTextAlignment(.leading)
                .padding(.top, 10.h)

            MeterBar(
                metricKey: metricKey,
                value: value,
                valueText: showsMeterValue ? formattedValue(value, for: metricKey) : nil,
                colors: gaugeColors
            )
            .frame(width: Screen.width * 0.52)
            .frame(height: 120.h)
            .frame(maxWidth: .infinity)
            .padding(.top, 24.h)

            Text(riskLabel)
                .font(.system(size: 34.sp, weight: .bold))
                .foregroundColor(Color(AppColors.black))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 22.h)

            HStack(alignment: .center, spacing: 24.w) {
                Circle()
                    .fill(indicatorColor)
                    .frame(width: 34.w, height: 34.h)

                Text(message)
                    .font(.system(size: 26.sp, weight: .semibold))
                    .foregroundColor(Color(AppColors.black))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 46.w)
            .padding(.vertical, 30.h)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20.r, style: .continuous))
            .padding(.horizontal, 12.w)
            .padding(.top, 34.h)
        }
        .padding(.horizontal, 42.w)
        .padding(.vertical, 40.h)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(AppColors.white))
        .overlay(
            RoundedRectangle(cornerRadius: 24.r, style: .continuous)
                .stroke(Color(AppColors.formBorder), lineWidth: 1.25)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24.r, style: .continuous))
    }
}

// ----------------------
// MeterBar with Sync'd Scaling
// ----------------------
struct MeterBar: View {
    let metricKey: String
    let value: Double
    let valueText: String?
    let colors: [Color]
    
    // Scale stops exactly matching Web (getResultsToDownload.tsx)
    private var fraction: Double {
        meterFraction(for: metricKey, value: value)
    }
    
    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let thumbWidth: CGFloat = 16.w
            let usableWidth = max(0, totalWidth - thumbWidth)
            let thumbX = CGFloat(fraction) * usableWidth
            let segmentSpacing: CGFloat = 4.w
            let segmentWidth = max(0, (totalWidth - segmentSpacing * CGFloat(max(colors.count - 1, 0))) / CGFloat(max(colors.count, 1)))
            
            ZStack(alignment: .topLeading) {
                HStack(spacing: segmentSpacing) {
                    ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                        RoundedRectangle(cornerRadius: 4.r, style: .continuous)
                            .fill(color)
                            .frame(width: segmentWidth, height: 28.h)
                    }
                }
                .offset(y: 70.h)

                if let valueText {
                    Text(valueText)
                        .font(.system(size: 34.sp, weight: .bold))
                        .foregroundColor(Color(AppColors.black))
                        .fixedSize()
                        .position(
                            x: min(max(thumbX + thumbWidth / 2, 86.w), totalWidth - 86.w),
                            y: 20.h
                        )
                }
                
                Rectangle()
                    .fill(Color(AppColors.black))
                    .frame(width: thumbWidth, height: 72.h)
                    .offset(x: thumbX)
                    .offset(y: 48.h)
            }
        }
    }
}

// ----------------------
// Helpers
// ----------------------
fileprivate func riskBucket(for key: String, value: Double) -> String {
    switch key {
    case "BP_CVD":
        if value < 5 { return "very_low" }
        if value < 7.25 { return "low" }
        if value < 10 { return "moderate_low" }
        if value < 20 { return "moderate" }
        return "high"
    case "HR_BPM":
        if value < 60 { return "low" }
        if value < 100 { return "normal" }
        return "high"
    case "BP_SYSTOLIC":
        if value < 90 { return "low" }
        if value < 130 { return "healthy" }
        if value < 140 { return "slightly_high" }
        return "high"
    case "BP_DIASTOLIC":
        if value < 60 { return "low" }
        if value < 70 { return "slightly_low" }
        if value < 80 { return "healthy" }
        if value < 90 { return "slightly_high" }
        return "high"
    case "HBA1C_RISK_PROB", "HDLTC_RISK_PROB", "TG_RISK_PROB":
        if value < 25 { return "very_low" }
        if value < 45 { return "low" }
        if value < 55 { return "moderate" }
        if value < 77.5 { return "high" }
        return "very_high"
    default:
        return "low"
    }
}

fileprivate func getTaggedMessage(metricKey: String, value: Double) -> String {
    let title = displayTitle(for: metricKey)
    let bucket = riskBucket(for: metricKey, value: value)
    return interpretationJSON[title]?[bucket] ?? interpretationJSON[title]?["low"] ?? ""
}

fileprivate func displayRiskLabel(for key: String, value: Double) -> String {
    switch key {
    case "BP_CVD":
        if value < 5 { return "Low Risk" }
        if value < 7.25 { return "Mildly Elevated Risk" }
        if value < 10 { return "Somewhat Elevated Risk" }
        if value < 20 { return "Elevated Risk" }
        return "Greatly Elevated Risk"

    case "HBA1C_RISK_PROB", "HDLTC_RISK_PROB", "TG_RISK_PROB":
        if value < 25 { return "Low Risk" }
        if value < 45 { return "Mildly Elevated Risk" }
        if value < 55 { return "Somewhat Elevated Risk" }
        if value < 77.5 { return "Elevated Risk" }
        return "Greatly Elevated Risk"

    case "BP_SYSTOLIC":
        if value < 90 { return "Below Expected Range" }
        if value < 120 { return "Mildly Below Expected Range" }
        if value < 130 { return "Within Expected Range" }
        if value < 140 { return "Mildly Above Expected Range" }
        return "Above Expected Range"

    case "BP_DIASTOLIC":
        if value < 60 { return "Below Expected Range" }
        if value < 70 { return "Mildly Below Expected Range" }
        if value < 80 { return "Within Expected Range" }
        if value < 90 { return "Mildly Above Expected Range" }
        return "Above Expected Range"

    case "HR_BPM":
        if value < 60 { return "Below Expected Range" }
        if value < 100 { return "Within Expected Range" }
        return "Above Expected Range"

    default:
        return "Low Risk"
    }
}

fileprivate func formattedValue(_ value: Double, for metricKey: String) -> String {
    switch metricKey {
    case "BP_CVD", "HBA1C_RISK_PROB", "HDLTC_RISK_PROB", "TG_RISK_PROB":
        return String(format: "%.2f%%", value)
    case "BP_SYSTOLIC", "BP_DIASTOLIC":
        return String(format: "%.0f mmHg", value)
    case "HR_BPM":
        return String(format: "%.0f bpm", value.rounded())
    default:
        return String(format: "%.2f", value)
    }
}

fileprivate func displayTitle(for key: String) -> String {
    ResultScreenStrings.Metrics.displayTitle(for: key)
}

fileprivate func descriptionText(for key: String) -> String {
    ResultScreenStrings.Metrics.description(for: key)
}

fileprivate func meterFraction(for key: String, value: Double) -> Double {
    scaleValueToRange(value, meterStops(for: key))
}

fileprivate func meterStops(for key: String) -> [Double] {
    switch key {
    case "BP_CVD": return [0, 5, 7.25, 10, 20, 100]
    case "BP_HEART_ATTACK": return [0, 1.65, 2.39, 3.3, 6.6, 33]
    case "BP_STROKE": return [0, 3.3, 4.79, 6.6, 13.2, 66]
    case "HR_BPM": return [0, 60, 100, 140]
    case "BR_BPM": return [0, 12, 16, 21, 25, 35]
    case "BP_SYSTOLIC": return [0, 90, 120, 130, 140, 180]
    case "BP_DIASTOLIC": return [0, 60, 70, 80, 90, 120]
    case "HRV_SDNN": return [0, 10.8, 16.4, 35.5, 49.9, 80]
    case "BP_RPP": return [0, 3.8, 3.9, 4.08, 4.18, 4.28]
    case "BP_TAU": return [0, 0.79, 1.12, 1.78, 2.11, 3]
    case "BMI_CALC": return [0, 18.5, 25, 30, 35, 60]
    case "WAIST_TO_HEIGHT": return [0, 43, 53, 58, 63, 75]
    default: return [0, 25, 45, 55, 77.5, 100]
    }
}

fileprivate func color(for bucket: String) -> Color {
    switch bucket {
    case "healthy", "low", "very_low", "normal", "moderate":
        return Color(AppColors.riskLow)
    case "warning", "medium", "moderate_low", "slightly_high":
        return Color(AppColors.riskWarning)
    case "critical", "high":
        return Color(AppColors.riskHigh)
    case "very_high":
        return Color(AppColors.riskHigh)
    default:
        return Color(AppColors.riskLow)
    }
}

fileprivate func meterColor(for key: String, value: Double, colors: [Color]) -> Color {
    guard !colors.isEmpty else { return Color(AppColors.riskLow) }
    if colors.count == 1 { return colors[0] }

    let fraction = min(max(meterFraction(for: key, value: value), 0), 1)
    let scaled = fraction * Double(colors.count - 1)
    let lowerIndex = Int(floor(scaled))
    let upperIndex = min(lowerIndex + 1, colors.count - 1)
    let localFraction = CGFloat(scaled - Double(lowerIndex))

    return interpolateColor(from: colors[lowerIndex], to: colors[upperIndex], fraction: localFraction)
}

fileprivate func meterBandColor(for key: String, value: Double, colors: [Color]) -> Color {
    guard !colors.isEmpty else { return Color(AppColors.riskLow) }
    if colors.count == 1 { return colors[0] }

    if key == "HR_BPM", colors.count >= 3 {
        if value < 60 { return colors[0] }
        if value < 100 { return colors[1] }
        return colors[2]
    }

    if key == "BP_CVD", colors.count >= 5 {
        if value < 5 { return colors[0] }
        if value < 7.25 { return colors[1] }
        if value < 10 { return colors[2] }
        if value < 20 { return colors[3] }
        return colors[4]
    }

    if key == "HBA1C_RISK_PROB" || key == "HDLTC_RISK_PROB" || key == "TG_RISK_PROB", colors.count >= 5 {
        if value < 25 { return colors[0] }
        if value < 45 { return colors[1] }
        if value < 55 { return colors[2] }
        if value < 77.5 { return colors[3] }
        return colors[4]
    }

    if key == "BP_SYSTOLIC", colors.count >= 5 {
        if value < 90 { return colors[0] }
        if value < 120 { return colors[1] }
        if value < 130 { return colors[2] }
        if value < 140 { return colors[3] }
        return colors[4]
    }

    if key == "BP_DIASTOLIC", colors.count >= 5 {
        if value < 60 { return colors[0] }
        if value < 70 { return colors[1] }
        if value < 80 { return colors[2] }
        if value < 90 { return colors[3] }
        return colors[4]
    }
    
    let stops = meterStops(for: key)
    guard stops.count >= 2 else { return colors[0] }

    if value <= stops[0] { return colors[0] }

    let segmentCount = stops.count - 1
    for index in 0..<segmentCount {
        if value > stops[index] && value <= stops[index + 1] {
            return colors[min(index, colors.count - 1)]
        }
    }

    return colors[min(segmentCount - 1, colors.count - 1)]
}

fileprivate func interpolateColor(from start: Color, to end: Color, fraction: CGFloat) -> Color {
    let startColor = UIColor(start)
    let endColor = UIColor(end)

    var startRed: CGFloat = 0
    var startGreen: CGFloat = 0
    var startBlue: CGFloat = 0
    var startAlpha: CGFloat = 0
    var endRed: CGFloat = 0
    var endGreen: CGFloat = 0
    var endBlue: CGFloat = 0
    var endAlpha: CGFloat = 0

    guard startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha),
          endColor.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha) else {
        return start
    }

    let red = startRed + (endRed - startRed) * fraction
    let green = startGreen + (endGreen - startGreen) * fraction
    let blue = startBlue + (endBlue - startBlue) * fraction
    let alpha = startAlpha + (endAlpha - startAlpha) * fraction

    return Color(uiColor: UIColor(red: red, green: green, blue: blue, alpha: alpha))
}

func scaleValueToRange(_ value: Double, _ stops: [Double]) -> Double {
    guard stops.count >= 2 else { return 0 }
    let v = min(max(value, stops.first!), stops.last!)
    let segmentCount = stops.count - 1
    let segmentWidth = 1.0 / Double(segmentCount)
    for i in 0..<segmentCount {
        if v >= stops[i] && v <= stops[i+1] {
            let local = (v - stops[i]) / (stops[i+1] - stops[i])
            return (Double(i) * segmentWidth) + (local * segmentWidth)
        }
    }
    return 1.0
}
