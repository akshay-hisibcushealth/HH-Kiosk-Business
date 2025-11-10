import SwiftUI

struct ResultsGrid: View {
    @ObservedObject var model: ResultsModel

    // Single column layout instead of 2-column grid
    private let columns = [
        GridItem(.flexible()) // one item per row
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(model.resultsArray, id: \.key) { pair in
                ResultCardView(
                    title: displayTitle(for: pair.key),
                    valueText: formattedValue(pair.value.value),
                    unit: unitForMetric(pair.key)
                )
                .frame(maxWidth: .infinity, minHeight: 100)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    private func displayTitle(for key: String) -> String {
        switch key {
        case "BP_CVD": return "Cardiovascular Risk"
        case "HBA1C_RISK_PROB": return "Hemoglobin A1C Risk"
        case "BP_SYSTOLIC": return "Systolic Blood Pressure"
        case "BP_DIASTOLIC": return "Diastolic Blood Pressure"
        case "HDLTC_RISK_PROB": return "Hypercholesterolemia Risk"
        case "TG_RISK_PROB": return "Hypertriglyceridemia Risk"
        case "HR_BPM": return "Heart Rate"
        default: return key.replacingOccurrences(of: "_", with: " ")
        }
    }

    private func unitForMetric(_ key: String) -> String? {
        switch key {
        case "BP_CVD", "HBA1C_RISK_PROB", "HDLTC_RISK_PROB", "TG_RISK_PROB": return "%"
        case "BP_SYSTOLIC", "BP_DIASTOLIC": return "mmHg"
        case "HR_BPM": return "bpm"
        default: return nil
        }
    }

    private func formattedValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
}


struct ResultCardView: View {
    let title: String
    let valueText: String
    let unit: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)

            HStack(spacing: 4) {
                Text(valueText)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.blue)
                if let unit {
                    Text(unit)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
                .shadow(radius: 1)
        )
    }
}
