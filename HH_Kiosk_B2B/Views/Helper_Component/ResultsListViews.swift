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
        ScrollView {
            VStack(spacing: 28.h) {
                ForEach(model.resultsArray, id: \.key) { pair in
                    ResultRow(
                        metricKey: pair.key,
                        title: displayTitle(for: pair.key),
                        subtitle: descriptionText(for: pair.key),
                        value: pair.value.value
                    )
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 16)
        }
    }
}

struct ResultRow: View {
    let metricKey: String
    let title: String
    let subtitle: String
    let value: Double

    private var message: AttributedString {
        attributedText(from: getTaggedMessage(metricKey: metricKey, value: value), fontSize: 24.sp)
    }

    private var indicatorColor: Color {
        meterBandColor(for: metricKey, value: value, colors: gaugeColors)
    }

    // Color logic from Web (getResultsToDownload.tsx)
    private var gaugeColors: [Color] {
        switch metricKey {
        case "BP_CVD", "HBA1C_RISK_PROB", "HDLTC_RISK_PROB", "TG_RISK_PROB":
            return meterBarColors
        case "HR_BPM":
            return heartRateMeterBarColors
        case "BP_SYSTOLIC", "BP_DIASTOLIC":
            return bloodPressureMeterBarColors
        case "BR_BPM":
            return [Color(AppColors.riskWarning), Color(AppColors.riskLow), Color(AppColors.riskLow), Color(AppColors.riskLow), Color(AppColors.riskWarning)]
        case "HRV_SDNN", "BP_TAU":
            return [Color(AppColors.gaugeCoral), Color(AppColors.gaugeSoftCoral), Color(AppColors.gaugePaleYellow), Color(AppColors.gaugeSoftGreen), Color(AppColors.gaugeDeepGreen)]
        case "BMI_CALC", "WAIST_TO_HEIGHT":
            return [Color(AppColors.gaugePaleYellow), Color(AppColors.gaugeSoftGreen), Color(AppColors.gaugePaleYellow), Color(AppColors.gaugeSoftCoral), Color(AppColors.gaugeCoral)]
        default:
            return [Color(AppColors.riskLow), Color(AppColors.accent), Color(AppColors.riskWarning), Color(AppColors.riskMedium), Color(AppColors.riskHigh)]
        }
    }

    private var meterBarColors: [Color] {
        [
            Color(AppColors.meterBarGreen),
            Color(AppColors.meterBarLime),
            Color(AppColors.meterBarYellow),
            Color(AppColors.meterBarCoral),
            Color(AppColors.meterBarRed)
        ]
    }

    private var bloodPressureMeterBarColors: [Color] {
        [
            Color(AppColors.meterBarYellow),
            Color(AppColors.meterBarGreen),
            Color(AppColors.meterBarLime),
            Color(AppColors.meterBarYellow),
            Color(AppColors.meterBarRed)
        ]
    }

    private var heartRateMeterBarColors: [Color] {
        [
            Color(AppColors.meterBarYellow),
            Color(AppColors.meterBarGreen),
            Color(AppColors.meterBarYellow)
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24.h) {
            VStack(alignment: .leading, spacing: 12.h) {
                HStack(alignment: .center, spacing: 14.w) {
                    Image(metricIconName(for: metricKey))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90.w, height: 90.h)

                    buildBoldText(title, 36.sp, color: Color(AppColors.black))
                }

                Text(subtitle)
                    .font(.system(size: 28.sp))
                    .foregroundColor(Color(AppColors.bodyText))
                    .lineSpacing(8.h)
                    .multilineTextAlignment(.leading)
            }

            HStack(alignment: .center, spacing: 24.w) {
                MeterBar(metricKey: metricKey, value: value, colors: gaugeColors)
                    .frame(width: Screen.width * 0.55, alignment: .leading)
                    .frame(minHeight: 86.h, maxHeight: 86.h)
                    .padding(.leading, 28.w)

                Spacer()

                buildBoldText(formattedValue(value, for: metricKey), 48.sp, color: Color(AppColors.black))
                    .frame(minWidth: 130.w, alignment: .trailing)
                    .padding(.trailing, 100.w)
            }
            .padding(.top, 6.h)

            HStack(alignment: .center, spacing: 18.w) {
                Circle()
                    .fill(indicatorColor)
                    .frame(width: 32.w, height: 32.h)

                buildMediumText(message, 24.sp, color: Color(AppColors.black))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24.w)
            .padding(.vertical, 22.h)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 24.r, style: .continuous))
            
            Divider()
        }
        .padding(.horizontal, 20.w)
        .padding(.vertical, 10.h)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// ----------------------
// MeterBar with Sync'd Scaling
// ----------------------
struct MeterBar: View {
    let metricKey: String
    let value: Double
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
            
            ZStack(alignment: .leading) {
                LinearGradient(
                    stops: gradientStops,
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 28.h)
                .clipShape(Capsule())
                
                Rectangle()
                    .fill(Color(AppColors.black))
                    .frame(width: thumbWidth, height: 68.h)
                    .offset(x: thumbX)
            }
        }
    }

    private var gradientStops: [Gradient.Stop] {
        guard !colors.isEmpty else {
            return [Gradient.Stop(color: Color.clear, location: 0)]
        }

        if colors.count == 1 {
            return [
                Gradient.Stop(color: colors[0], location: 0),
                Gradient.Stop(color: colors[0], location: 1)
            ]
        }

        let step = 1.0 / Double(colors.count - 1)
        return colors.enumerated().map { index, color in
            Gradient.Stop(color: color, location: step * Double(index))
        }
    }
}

// ----------------------
// Helpers
// ----------------------
fileprivate func riskBucket(for key: String, value: Double) -> String {
    switch key {
    case "BP_CVD":
        if value <= 5 { return "very_low" }
        if value <= 7.25 { return "low" }
        if value <= 10 { return "moderate_low" }
        if value <= 20 { return "moderate" }
        return "high"
    case "HR_BPM":
        if value <= 60 { return "moderate" }
        if value <= 100 { return "normal" }
        if value <= 120 { return "slightly_high" }
        if value <= 140 { return "high" }
        return "very_high"
    case "BP_SYSTOLIC":
        if value <= 90 { return "low" }
        if value <= 130 { return "healthy" }
        if value <= 140 { return "slightly_high" }
        return "high"
    case "BP_DIASTOLIC":
        if value <= 60 { return "low" }
        if value <= 70 { return "slightly_low" }
        if value <= 80 { return "healthy" }
        if value <= 90 { return "slightly_high" }
        return "high"
    case "HBA1C_RISK_PROB", "HDLTC_RISK_PROB", "TG_RISK_PROB":
        if value <= 25 { return "very_low" }
        if value <= 45 { return "low" }
        if value <= 55 { return "moderate" }
        if value <= 77.5 { return "high" }
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

fileprivate func formattedValue(_ value: Double, for metricKey: String) -> String {
    switch metricKey {
    case "BP_CVD", "HBA1C_RISK_PROB", "HDLTC_RISK_PROB", "TG_RISK_PROB":
        return String(format: "%.2f%%", value)
    case "BP_SYSTOLIC", "BP_DIASTOLIC":
        return String(format: "%.0f mmHg", value)
    case "HR_BPM":
        return String(format: "%.0f bpm", floor(value))
    default:
        return String(format: "%.2f", value)
    }
}

fileprivate func displayTitle(for key: String) -> String {
    ResultScreenStrings.Metrics.displayTitle(for: key)
}

fileprivate func metricIconName(for key: String) -> String {
    switch key {
    case "BP_CVD":
        return AppIconNames.Asset.cvdRiskIcon
    case "BP_SYSTOLIC":
        return AppIconNames.Asset.systolicBloodPressureIcon
    case "BP_DIASTOLIC":
        return AppIconNames.Asset.diastolicBloodPressureIcon
    case "HBA1C_RISK_PROB":
        return AppIconNames.Asset.hba1cIcon
    case "HDLTC_RISK_PROB":
        return AppIconNames.Asset.cholesterolIcon
    case "TG_RISK_PROB":
        return AppIconNames.Asset.triglyceridesIcon
    default:
        return AppIconNames.Asset.hrIcon
    }
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

fileprivate func attributedText(from text: String, fontSize: CGFloat = 16) -> AttributedString {
    var result = AttributedString(text)
    result.font = .custom("NewSpirit-Bold", size: fontSize)
    result.foregroundColor = Color(AppColors.bodyText)
    return result
}
