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
            VStack(spacing: 12) {
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

    // Color logic from Web (getResultsToDownload.tsx)
    private var gaugeColors: [Color] {
        switch metricKey {
        case "BP_SYSTOLIC", "BP_DIASTOLIC":
            return [Color(AppColors.riskWarning), Color(AppColors.riskLow), Color(AppColors.ctaGreen), Color(AppColors.riskWarning), Color(AppColors.riskHigh)]
        case "HR_BPM", "BR_BPM":
            return [Color(AppColors.gaugePaleYellow), Color(AppColors.gaugeSoftGreen), Color(AppColors.gaugeSoftGreen), Color(AppColors.gaugeSoftGreen), Color(AppColors.gaugePaleYellow)]
        case "HRV_SDNN", "BP_TAU":
            return [Color(AppColors.gaugeCoral), Color(AppColors.gaugeSoftCoral), Color(AppColors.gaugePaleYellow), Color(AppColors.gaugeSoftGreen), Color(AppColors.gaugeDeepGreen)]
        case "BMI_CALC", "WAIST_TO_HEIGHT":
            return [Color(AppColors.gaugePaleYellow), Color(AppColors.gaugeSoftGreen), Color(AppColors.gaugePaleYellow), Color(AppColors.gaugeSoftCoral), Color(AppColors.gaugeCoral)]
        default:
            return [Color(AppColors.riskLow), Color(AppColors.ctaGreen), Color(AppColors.riskWarning), Color(AppColors.riskMedium), Color(AppColors.riskHigh)]
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Title + Subtitle (Preserving iOS Styles)
            VStack(alignment: .leading, spacing: 6) {
                buildBoldText(title, 24.sp, color: Color(AppColors.primary))
                Text(subtitle)
                    .font(.system(size: 22.sp))
                    .foregroundColor(Color(AppColors.bodyText))
                    .multilineTextAlignment(.leading)
            }

            // Meter + Value + Result Text
            HStack(alignment: .center, spacing: 16) {
                MeterBar(metricKey: metricKey, value: value, colors: gaugeColors)
                    .frame(width: 310.w, height: 50.h)
                
                Spacer()
                buildBoldText(formattedValue(value, for: metricKey), 34.sp, color: Color(AppColors.bodyText))
                Spacer()

                let msg = getTaggedMessage(metricKey: metricKey, value: value)
                let attr = attributedText(from: msg, fontSize: 20.sp)
                buildMediumText(attr, 20.sp)
                    .frame(width: 340.w, alignment: .leading)
                    .padding(.trailing, 48.w)
            }
            .padding(.horizontal, 32.h)
            .padding(.bottom, 32.h)

            Divider().background(Color(AppColors.gray).opacity(0.3))
        }
        .padding(.vertical, 6.h)
        .padding(.horizontal, 24.w)
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
        switch metricKey {
        case "BP_CVD": return scaleValueToRange(value, [0, 5, 7.25, 10, 20, 100])
        case "BP_HEART_ATTACK": return scaleValueToRange(value, [0, 1.65, 2.39, 3.3, 6.6, 33])
        case "BP_STROKE": return scaleValueToRange(value, [0, 3.3, 4.79, 6.6, 13.2, 66])
        case "HR_BPM": return scaleValueToRange(value, [0, 60, 73.3, 88, 100, 140])
        case "BR_BPM": return scaleValueToRange(value, [0, 12, 16, 21, 25, 35])
        case "BP_SYSTOLIC": return scaleValueToRange(value, [0, 90, 120, 130, 140, 180])
        case "BP_DIASTOLIC": return scaleValueToRange(value, [0, 60, 70, 80, 90, 120])
        case "HRV_SDNN": return scaleValueToRange(value, [0, 10.8, 16.4, 35.5, 49.9, 80])
        case "BP_RPP": return scaleValueToRange(value, [0, 3.8, 3.9, 4.08, 4.18, 4.28])
        case "BP_TAU": return scaleValueToRange(value, [0, 0.79, 1.12, 1.78, 2.11, 3])
        case "BMI_CALC": return scaleValueToRange(value, [0, 18.5, 25, 30, 35, 60])
        case "WAIST_TO_HEIGHT": return scaleValueToRange(value, [0, 43, 53, 58, 63, 75])
        default: return scaleValueToRange(value, [0, 25, 45, 55, 77.5, 100])
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let thumbWidth: CGFloat = 15.w
            let usableWidth = max(0, totalWidth - thumbWidth)
            let thumbX = CGFloat(fraction) * usableWidth
            
            ZStack(alignment: .leading) {
                LinearGradient(
                    stops: gradientStops,
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 12.h)
                .clipShape(Capsule())
                
                // Indicator (Thumb)
                Rectangle()
                    .fill(Color(AppColors.primary)) // Matching Web Indicator Color
                    .frame(width: thumbWidth, height: 40.h)
                    .cornerRadius(5.r)
                    .offset(x: thumbX, y: (geo.size.height - 40.h) / 2)
                    .shadow(radius: 1)
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
        return value <= 7.25 ? "low" : (value < 10 ? "medium" : "high")
    case "BP_SYSTOLIC":
        if value >= 140 { return "critical" }
        if (90..<130).contains(value) { return "healthy" }
        return "warning"
    case "BP_DIASTOLIC":
        if value >= 90 { return "critical" }
        if (60..<80).contains(value) { return "healthy" }
        return "warning"
    case "HBA1C_RISK_PROB", "HDLTC_RISK_PROB", "TG_RISK_PROB":
        return value <= 45 ? "low" : (value <= 55 ? "medium" : "high")
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
        return String(format: "%.1f bpm", value)
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

fileprivate func attributedText(from taggedString: String, fontSize: CGFloat = 16) -> AttributedString {
    var result = AttributedString()
    var remaining = taggedString
    while let startRange = remaining.range(of: "<tag color=\""),
          let colorEndIdx = remaining[startRange.upperBound...].firstIndex(of: "\""),
          let tagCloseStart = remaining.range(of: "\">", range: colorEndIdx..<remaining.endIndex),
          let tagEndRange = remaining.range(of: "</tag>") {
        let before = String(remaining[..<startRange.lowerBound])
        if !before.isEmpty {
            var a = AttributedString(before)
            a.font = .custom("NewSpirit-Medium", size: fontSize)
            a.foregroundColor = Color(AppColors.bodyText)
            result.append(a)
        }
        let content = String(remaining[tagCloseStart.upperBound..<tagEndRange.lowerBound])
        var boldText = AttributedString(content)
        boldText.font = .custom("NewSpirit-Medium", size: fontSize).weight(.bold)
        boldText.foregroundColor = Color(AppColors.bodyText)
        result.append(boldText)
        remaining = String(remaining[tagEndRange.upperBound...])
    }
    if !remaining.isEmpty {
        var a = AttributedString(remaining)
        a.font = .custom("NewSpirit-Medium", size: fontSize)
        a.foregroundColor = Color(AppColors.bodyText)
        result.append(a)
    }
    return result
}
