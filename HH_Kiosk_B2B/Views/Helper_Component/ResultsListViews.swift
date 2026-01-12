import SwiftUI

// ----------------------
// Tagged interpretation JSON (use only one set at runtime)
// ----------------------

let interpretationJSON: [String: [String: String]] = [
    "Cardiovascular Disease Risk": [
        "low": """
        Your results indicate that you have a <tag color="#1DC833">low risk</tag> of experiencing a heart attack or stroke in the next 10 years.
        """,
        "medium": """
        Your results indicate that you have a <tag color="#FFCB59">medium risk</tag> of experiencing a heart attack or stroke in the next 10 years.
        """,
        "high": """
        Your results indicate that you have a <tag color="#B32D0C">high risk</tag> of experiencing a heart attack or stroke in the next 10 years.
        """
    ],

    "Systolic Blood Pressure": [
        // include both variants to avoid mismatches with displayTitle(for:)
        "low_high": """
        Your results indicate that your systolic blood pressure is <tag color="#FD895A">either lower than normal or higher than normal</tag>.
        """,
        "low_normal_high": """
        Your results indicate that your systolic blood pressure is <tag color="#FD895A">either lower than normal or higher than normal</tag>.
        """,
        "healthy_light": """
        Your results indicate that your systolic blood pressure is <tag color="#FD895A">either lower than normal or higher than normal</tag>.
        """,
        "healthy": """
        Your results indicate that your systolic blood pressure falls within a <tag color="#1DC833">healthy range</tag>.
        """,
        "very_high": """
        Your results indicate that your systolic blood pressure is <tag color="#B32D0C">much higher than normal</tag> and that you may have hypertension.
        """
    ],

    "Diastolic Blood Pressure": [
        "healthy": """
        Your results indicate that your diastolic blood pressure is <tag color="#1DC833">within a healthy range</tag>.
        """,
        "low_high": """
        Your results indicate that your diastolic blood pressure is <tag color="#FD895A">either lower than normal or higher than normal</tag>.
        """,
        "healthy_light": """
        Your results indicate that your diastolic blood pressure is <tag color="#FD895A">either lower than normal or higher than normal</tag>.
        """,
        "very_high": """
        Your results indicate that your diastolic blood pressure is <tag color="#B32D0C">much higher than normal</tag> and that you may have hypertension.
        """
    ],

    // include both variants to avoid mismatches with displayTitle(for:)
    "Hemoglobin A1C Risk": [
        "low": """
        Your results indicate that you likely have a <tag color="#1DC833">HbA1c < 5.7%</tag>.
        """,
        "medium": """
        Your results indicate that there is a <tag color="#FFCB59">medium risk</tag> that you may have an HbA1c > 5.7%, especially if your results are 5.7% or higher.
        """,
        "high": """
        Your results indicate that it is <tag color="#B32D0C">very likely</tag> that you have an HbA1c > 5.7%.
        """
    ],
    "HbA1c Risk": [
        "low": """
        Your results indicate that you likely have a <tag color="#1DC833">HbA1c < 5.7%</tag>.
        """,
        "medium": """
        Your results indicate that there is a <tag color="#FFCB59">medium risk</tag> that you may have an HbA1c > 5.7%, especially if your results are 5.7% or higher.
        """,
        "high": """
        Your results indicate that it is <tag color="#B32D0C">very likely</tag> that you have an HbA1c > 5.7%.
        """
    ],

    "Hypercholesterolemia Risk": [
        "low": """
        Your results indicate that you are at a <tag color="#1DC833">low risk</tag> of having abnormally high cholesterol.
        """,
        "medium": """
        Your results indicate that you are at a <tag color="#FFCB59">medium risk</tag> of having abnormally high cholesterol.
        """,
        "high": """
        Your results indicate that you are at a <tag color="#B32D0C">high risk</tag> of having abnormally high cholesterol.
        """
    ],

    "Hypertriglyceridemia Risk": [
        "low": """
        Your results indicate that you are at a <tag color="#1DC833">low risk</tag> of having abnormally high triglycerides.
        """,
        "medium": """
        Your results indicate that you are at a <tag color="#FFCB59">medium risk</tag> of having abnormally high triglycerides.
        """,
        "high": """
        Your results indicate that you are at a <tag color="#B32D0C">high risk</tag> of having abnormally high triglycerides.
        """
    ]
]



// ----------------------
// UI: ResultsList & ResultRow
// ----------------------

struct ResultsList: View {
    @ObservedObject var model: ResultsModel

    var body: some View {
        VStack(spacing: 12) {
            ForEach(model.resultsArray, id: \.key) { pair in
                ResultRow(
                    metricKey: pair.key,
                    title: displayTitle(for: pair.key),
                    subtitle: descriptionText(for: pair.key),
                    value: pair.value.value,
                    minValue: minForMetric(pair.key),
                    maxValue: maxForMetric(pair.key)
                )
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
    }
}

// MARK: - Single Row
struct ResultRow: View {
    let metricKey: String
    let title: String
    let subtitle: String
    let value: Double
    let minValue: Double
    let maxValue: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Title + Subtitle
            VStack(alignment: .leading, spacing: 6) {
                buildBoldText(title, 24.sp, color: Color(hex: "#1E4B86"))
                Text(subtitle)
                    .font(.system(size: 22.sp))
                    .foregroundColor(Color(hex: "#333333"))
                    .multilineTextAlignment(.leading)
            }

            // Meter + Value + Result
            HStack(alignment: .center, spacing: 16) {
                MeterBar(metricKey: metricKey,value: value, minValue: minValue, maxValue: maxValue)
                    .frame(width: 310.w, height: 50.h) // give enough height for thumb
                Spacer()
                buildBoldText(formattedValue(value, for: metricKey), 34.sp, color: Color(hex: "#333333"))
                Spacer()

                // Get tagged message → convert to AttributedString → show
                let msg = getTaggedMessage(metricKey: metricKey, value: value)
                let attr = attributedText(from: msg, fontSize: 20.sp)
                buildMediumText(attr, 20.sp).frame(width: 340.w, alignment: .leading).padding(.trailing,48.w)

            }
            .padding(.horizontal,32.h)
            .padding(.bottom,32.h)

            Divider().background(Color.gray.opacity(0.3))
        }
        .padding(.vertical, 6.h)
        .padding(.horizontal, 24.w)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// ----------------------
// MeterBar (kept mostly same)
// ----------------------
struct MeterBar: View {
    let metricKey: String
    let value: Double
    let minValue: Double
    let maxValue: Double
    
    
    private var fraction: Double {
        if metricKey == "BP_CVD" {
            return cvdFraction(value)
        }
        else if metricKey == "BP_SYSTOLIC" {
            return scaleValueToRange(value, [0, 90, 120, 130, 140, 180])
        }
        else if metricKey == "BP_DIASTOLIC" {
            return scaleValueToRange(value, [0, 60, 70, 80, 90, 120])
        }
        else {
            return riskProbabilityFraction(value)
        }
    }
    
    fileprivate func cvdFraction(_ value: Double) -> Double {
        switch value {
        case ..<5.0:   return 0.0    // Very Low
        case ..<7.5:   return 0.25   // Low/Borderline
        case ..<10.0:  return 0.50   // Medium
        case ..<20.0:  return 0.75   // High
        default:       return 1.0    // Very High
        }
    }
    
    
    
    private let bloodPressureSegments: [Color] = [
        Color(hex: "#FFCB59"),
        Color(hex: "#1DC833"),
        Color(hex: "#B8EB5E"),
        Color(hex: "#FFCB59"),
        Color(hex: "#B32D0C")
    ]
    
    private let othersSegments: [Color] = [
        Color(hex: "#1DC833"),
        Color(hex: "#B8EB5E"),
        Color(hex: "#FFCB59"),
        Color(hex: "#FD895A"),
        Color(hex: "#B32D0C")
    ]
    
    // ✅ Use a computed property for conditional assignment
    private var segments: [Color] {
        if metricKey == "BP_SYSTOLIC" || metricKey == "BP_DIASTOLIC" {
            return bloodPressureSegments
        } else {
            return othersSegments
        }
    }
    
    // fixed sizes
    private let thumbWidth: CGFloat = 15.w
    private let thumbHeight: CGFloat = 40.h
    private let barHeight: CGFloat = 12.h
    
    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let usableWidth = max(0, totalWidth - thumbWidth)
            let thumbX = CGFloat(fraction) * usableWidth
            
            ZStack(alignment: .leading) {
                // bar
                HStack(spacing: 0) {
                    ForEach(0..<segments.count, id: \.self) { i in
                        Rectangle()
                            .fill(segments[i])
                            .frame(width: totalWidth / CGFloat(segments.count),
                                   height: barHeight)
                    }
                }
                .cornerRadius(barHeight / 2)
                .overlay(
                    RoundedRectangle(cornerRadius: barHeight / 2)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .frame(width: totalWidth, height: barHeight)
                
                // thumb
                Rectangle()
                    .fill(Color(hex: "#4D4D4D"))
                    .frame(width: thumbWidth, height: thumbHeight)
                    .cornerRadius(5.r)
                    .offset(x: thumbX, y: (geo.size.height - thumbHeight) / 2)
                    .shadow(radius: 1)
            }
        }
        .frame(height: 50.h)
    }
    
    private func normalizedFraction() -> Double {
        guard maxValue - minValue > 0 else { return 0 }
        let clipped = min(max(value, minValue), maxValue)
        return (clipped - minValue) / (maxValue - minValue)
    }
    
    
    fileprivate func riskProbabilityFraction(_ value: Double) -> Double {
        switch value {
        case ..<25:   return 0.0
        case ..<45:   return 0.25
        case ..<55:   return 0.50
        case ..<75:   return 0.75
        default:      return 1.0
        }
    }
}


// ----------------------
// Helpers & mapping functions
// ----------------------

fileprivate func formattedValue(_ value: Double, for metricKey: String) -> String {
    switch metricKey {
    case "BP_CVD", "HBA1C_RISK_PROB", "HDLTC_RISK_PROB", "TG_RISK_PROB":
        return String(format: "%.2f%%", value)
    case "BP_SYSTOLIC", "BP_DIASTOLIC":
        return String(format: "%.0f mmHg", value)
    default:
        return String(format: "%.2f", value)
    }
}

fileprivate func displayTitle(for key: String) -> String {
    switch key {
    case "BP_CVD": return "Cardiovascular Disease Risk"
    case "HBA1C_RISK_PROB": return "Hemoglobin A1C Risk"
    case "BP_SYSTOLIC": return "Systolic Blood Pressure"
    case "BP_DIASTOLIC": return "Diastolic Blood Pressure"
    case "HDLTC_RISK_PROB": return "Hypercholesterolemia Risk"
    case "TG_RISK_PROB": return "Hypertriglyceridemia Risk"
    default: return key.replacingOccurrences(of: "_", with: " ")
    }
}

fileprivate func descriptionText(for key: String) -> String {
    switch key {
    case "BP_CVD":
        return "Cardiovascular Disease Risk is your likelihood of experiencing your first heart attack or stroke within the next 10 years. expressed as a percentage."
    case "BP_SYSTOLIC":
        return "Systolic blood pressure is the peak pressure in your brachial arteries during the contraction of your heart muscle, measured in millimeters of mercury (mmHg)."
    case "BP_DIASTOLIC":
        return "Diastolic blood pressure is the amount of pressure in your brachial arteries when your heart muscle is relaxed, measured in millimeters of mercury (mmHg)."
    case "HBA1C_RISK_PROB":
        return "A hemoglobin A1C (HbA1C) test is a blood test that measures the amount of glucose (sugar) attached to the hemoglobin in your red blood cells."
    case "HDLTC_RISK_PROB":
        return "Hypercholesterolemia is when you have high amounts of cholesterol in the blood. High cholesterol can limit blood flow, increasing the risk of a heart attack or stroke."
    case "TG_RISK_PROB":
        return "Hypertriglyceridemia is when you have an abnormally high level of a certain type of fat (triglycerides) in the blood, defined above 1.7 mmol/L or 150 mg/dL."
    default:
        return ""
    }
}

fileprivate func minForMetric(_ key: String) -> Double {
    switch key {
    case "BP_CVD", "HBA1C_RISK_PROB", "HDLTC_RISK_PROB", "TG_RISK_PROB":
        return 0.0
    case "BP_SYSTOLIC":
        return 0.0
    case "BP_DIASTOLIC":
        return 0.0
    case "HR_BPM":
        return 0.0
    default:
        return 0.0
    }
}

fileprivate func maxForMetric(_ key: String) -> Double {
    switch key {
    case "BP_CVD", "HBA1C_RISK_PROB", "HDLTC_RISK_PROB", "TG_RISK_PROB":
        return 100.0
    case "BP_SYSTOLIC":
        return 180.0
    case "BP_DIASTOLIC":
        return 120.0
    case "HR_BPM":
        return 140.0
    default:
        return 100.0
    }
}

// Decide bucket (simple thresholds — tune as needed)
fileprivate func riskBucket(for key: String, value: Double) -> String {
    switch key {
    case "BP_CVD", "HBA1C_RISK_PROB", "HDLTC_RISK_PROB", "TG_RISK_PROB":
        if value >= 66 { return "high" }
        if value >= 34 { return "medium" }
        return "low"
    case "BP_SYSTOLIC":
        if value >= 140 { return "very_high" }
        if value >= 130 { return "low_high" }
        if value >= 120 { return "healthy_light" }
        if value >= 90  { return "healthy" }
        return "low_high"

    case "BP_DIASTOLIC":
        if value >= 90 { return "very_high" }
        if value >= 80 { return "low_high" }
        if value >= 70 { return "healthy_light" }
        if value >= 60 { return "healthy" }
        return "low_high"

    case "HR_BPM":
        // example: normal 60-100
        if value >= 60 && value <= 100 { return "normal" }
        return "out_of_range"
    default:
        return "low"
    }
}

// Map metric key -> message from interpretationJSON using displayTitle
fileprivate func getTaggedMessage(metricKey: String, value: Double) -> String {
    let title = displayTitle(for: metricKey)
    let bucket = riskBucket(for: metricKey, value: value)
    if let msg = interpretationJSON[title]?[bucket] {
        return msg
    }
    // fallback: try "low" if bucket missing
    return interpretationJSON[title]?["low"] ?? ""
}

// ----------------------
// Tag parser: converts <tag color="#HEX">text</tag> → AttributedString with color
// ----------------------
fileprivate func attributedText(
    from taggedString: String,
    fontSize: CGFloat = 16
) -> AttributedString {

    var result = AttributedString()
    var remaining = taggedString

    func makePlain(_ s: String) -> AttributedString {
        var a = AttributedString(s)
        a.font = .custom("NewSpirit-Medium", size: fontSize)
        a.foregroundColor = Color(hex: "#333333")   // normal text color
        return a
    }

    while let startRange = remaining.range(of: "<tag color=\""),
          let colorEndIdx = remaining[startRange.upperBound...].firstIndex(of: "\""),
          let tagCloseStart = remaining.range(of: "\">", range: colorEndIdx..<remaining.endIndex),
          let tagEndRange = remaining.range(of: "</tag>") {

        // text before tag
        let before = String(remaining[..<startRange.lowerBound])
        if !before.isEmpty {
            result.append(makePlain(before))
        }

        // tagged content → bold only
        let content = String(remaining[tagCloseStart.upperBound..<tagEndRange.lowerBound])

        var boldText = AttributedString(content)
        boldText.font = .custom("NewSpirit-Medium", size: fontSize).weight(.bold)
        boldText.foregroundColor = Color(hex: "#333333") // SAME color as normal text

        result.append(boldText)

        remaining = String(remaining[tagEndRange.upperBound...])
    }

    if !remaining.isEmpty {
        result.append(makePlain(remaining))
    }

    return result
}

func scaleValueToRange(_ value: Double, _ stops: [Double]) -> Double {
    guard stops.count >= 2 else { return 0 }

    let maxStop = stops.last!
    let minStop = stops.first!

    let v = Swift.min(Swift.max(value, minStop), maxStop)

    let segmentCount = stops.count - 1
    let segmentWidth = 1.0 / Double(segmentCount)

    for i in 0..<segmentCount {
        let start = stops[i]
        let end = stops[i + 1]

        if v >= start && v <= end {
            let local = (v - start) / (end - start)
            return Double(i) * segmentWidth + local * segmentWidth
        }
    }

    return 1.0
}





extension MeterBar {
    func colorForValue(_ value: Double) -> Color {
        let normalized = normalizedFraction()
        let idx = Int(normalized * Double(segments.count - 1))
        return segments[max(0, min(idx, segments.count - 1))]
    }
}


fileprivate func colorForMetricValue(_ key: String, _ value: Double) -> Color {
    let very_low = Color(hex: "#1DC833")
    let low = Color(hex: "#B8EB5E")
    let medium = Color(hex: "#FFCB59")
    let high = Color(hex: "#FD895A")
    let very_high =  Color(hex: "#B32D0C")

    let low_for_blood_pressure = Color(hex: "#82D79F")
    let high_for_blood_pressure = Color(hex: "#FBED95")
    let very_high_for_blood_pressure =  Color(hex: "#EC635E")
    
    switch key {
    case "BP_CVD", "HBA1C_RISK_PROB", "HDLTC_RISK_PROB", "TG_RISK_PROB":
        if value <= 20 { return very_low }
        if value <= 40 { return low }
        if value <= 60 { return medium }
        if value <= 80 { return high }
        return very_high                      
    case "BP_SYSTOLIC":
        if value >= 140 { return very_high_for_blood_pressure }
        if value >= 90 && value < 130 { return low_for_blood_pressure }
        return high_for_blood_pressure
    case "BP_DIASTOLIC":
        if value >= 90 { return very_high_for_blood_pressure }
        if value >= 60 && value < 80 { return low_for_blood_pressure }
        return high_for_blood_pressure
    default:
        return Color(hex: "#333333")
    }
}
