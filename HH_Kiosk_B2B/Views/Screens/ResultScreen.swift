import SwiftUI
import Combine
import AnuraCore

// MARK: - Models
public struct SignalResult: Decodable {
    public let notes: [String]
    public let value: Double

    public init(notes: [String], value: Double) {
        self.notes = notes
        self.value = value
    }
}

public typealias ResultsMap = [String: SignalResult]

public final class ResultsModel: ObservableObject {
    @Published public var results: ResultsMap = [:]

    private let displayOrder: [String] = [
        "BP_SYSTOLIC",
        "BP_DIASTOLIC",
        "HR_BPM",
        "HBA1C_RISK_PROB",
        "HDLTC_RISK_PROB",
        "TG_RISK_PROB",
        "BP_CVD"
    ]

    public var resultsArray: [(key: String, value: SignalResult)] {
        let sorted = results.sorted { lhs, rhs in
            let leftIndex = displayOrder.firstIndex(of: lhs.key) ?? Int.max
            let rightIndex = displayOrder.firstIndex(of: rhs.key) ?? Int.max
            return leftIndex < rightIndex
        }
        return Array(sorted)
    }

    public init() {}

    public func update(with newResults: ResultsMap) {
        DispatchQueue.main.async {
            self.results = newResults
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Main Screen
public struct ResultScreen: View {
    @StateObject private var model: ResultsModel
    let result: [String: MeasurementResults.SignalResult]
    @State private var refreshTrigger = false
    @State private var isLandscape = false
    
    // PDF States
    @State private var pdfURL: URL?
    @State private var isSharing = false

    private let showBottomButtons: Bool
    private let showLoadingOverlay: Bool
    private let debugSkipToResultsAction: (() -> Void)?
    
    public init(
        model: ResultsModel = ResultsModel(),
        result: [String: MeasurementResults.SignalResult] = [:],
        showBottomButtons: Bool = true,
        showLoadingOverlay: Bool = true,
        debugSkipToResultsAction: (() -> Void)? = nil
    ) {
        _model = StateObject(wrappedValue: model)
        self.result = result
        self.showBottomButtons = showBottomButtons
        self.showLoadingOverlay = showLoadingOverlay
        self.debugSkipToResultsAction = debugSkipToResultsAction
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                mainContentView(isLandscape: isLandscape) // Extracted for reuse in PDF
                    .padding(.bottom, showBottomButtons ? 150.h : 0)
            }
            .ignoresSafeArea(edges: .top)
            
            if showBottomButtons {
                ResultScreenButtons(result: result, onDownloadPDF: {
                    exportToPDF()
                },onPrint: {})
            }

            #if DEBUG
            if let debugSkipToResultsAction {
                Button(action: debugSkipToResultsAction) {
                    Label(
                        PhysicalAttributesScreenStrings.debugRefresh,
                        systemImage: "arrow.clockwise"
                    )
                    .font(.system(size: 18.sp, weight: .bold))
                    .foregroundColor(Color(AppColors.white))
                    .padding(.horizontal, 24.w)
                    .frame(minHeight: 52.h)
                    .background(Color(AppColors.primary))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.18), radius: 8.r, y: 4.h)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 28.w)
                .padding(.bottom, showBottomButtons ? 130.h : 28.h)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .accessibilityHint("Submits mock scan data and reloads the results")
            }
            #endif
        }
        .onGeometryChange(for: Bool.self) { geometry in
            geometry.size.width > geometry.size.height
        } action: { newValue in
            isLandscape = newValue
        }
        .onReceive(NotificationCenter.default.publisher(for: .screenDidChangeBounds)) { _ in
            refreshTrigger.toggle()
        }
        .sheet(isPresented: $isSharing, onDismiss: {
            PDFGenerator.removeTemporaryPHIFile(at: pdfURL)
            pdfURL = nil
        }) {
            if let url = pdfURL {
                ShareSheet(activityItems: [url])
            }
        }

    }
    
    // Extracted content view so we can render it without the ScrollView wrapper for PDF
    private func mainContentView(isLandscape: Bool = false, showsProgress: Bool = true) -> some View {
        VStack(spacing: 0) {
            HeroHeader(showsProgress: showsProgress, isLandscape: isLandscape)
            ResultsList(model: model, isLandscape: isLandscape)
        }
        .frame(maxWidth: .infinity)
        .background(Color(AppColors.resultHeroBackground))
    }
    
    private func exportToPDF() {
        // We render the raw content (without the ScrollView) to ensure we get the full length
        let pdfView = mainContentView(showsProgress: false).frame(width: 595) // Fix width to A4
        
        if let url = PDFGenerator.generatePDF(view: pdfView, fileName: ResultScreenStrings.pdfFileName) {
            self.pdfURL = url
            self.isSharing = true
        }
    }
}

// MARK: - Subviews
private struct HeroHeader: View {
    let showsProgress: Bool
    let isLandscape: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ResultToolbar(isLandscape: isLandscape)

            if showsProgress {
                ScanProgressView(currentStep: .report)
            }

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 28.w) {
                    Text(ResultScreenStrings.reportLabel)
                        .font(.system(size: 20.sp, weight: .semibold))
                        .tracking(1.2)
                        .foregroundColor(Color(AppColors.resultReportLabel))

                    Spacer(minLength: 24.w)
                }

                Text(ResultScreenStrings.title)
                    .font(.system(size: 44.sp, weight: .medium))
                    .foregroundColor(Color(AppColors.scheduleTitleText))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .padding(.top, 26.h)

                TitleBlock()
                    .padding(.top, 28.h)
            }
            .padding(.horizontal, 42.w)
            .padding(.top, 48.h)
            .padding(.bottom, 16.h)
            .background(Color(AppColors.resultHeroBackground))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct TitleBlock: View {
    private var titleBlockDescription: String {
        ResultScreenStrings.titleBlockDescription
    }

    var body: some View {
        Text(titleBlockDescription)
        .font(.system(size: 24.sp, weight: .regular))
        .foregroundColor(Color(AppColors.scheduleTitleText))
        .italic()
        .lineSpacing(10.h)
        .padding(.horizontal, 46.w)
        .padding(.vertical, 24.h)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(AppColors.white))
        .overlay(
            RoundedRectangle(cornerRadius: 16.r, style: .continuous)
                .stroke(Color(AppColors.formBorder), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16.r, style: .continuous))
    }
}

private struct InfoFooter: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8.r, style: .continuous)
                .fill(Color(AppColors.resultAlertBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8.r, style: .continuous)
                        .stroke(Color(AppColors.resultAlertBorder), lineWidth: 1)
                )
                .frame(maxWidth: .infinity)
                .frame(minHeight: 105.h, maxHeight: 105.h)
            
            HStack(spacing: 12.w) {
                Image(systemName: AppIconNames.Symbol.infoCircle)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(AppColors.resultAlertBorder))
                    .padding(.leading, 12.w)
                
                Text(ResultScreenStrings.infoFooter)
                    .font(.system(size: 18.sp))
                    .foregroundColor(Color(AppColors.resultAlertText))
                    .italic()
                    .padding(12.w)
            }
        }
    }
}


struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
