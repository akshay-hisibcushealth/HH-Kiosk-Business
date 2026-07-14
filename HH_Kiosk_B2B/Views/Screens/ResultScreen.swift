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
        "BP_CVD",
        "BP_SYSTOLIC",
        "BP_DIASTOLIC",
        "HBA1C_RISK_PROB",
        "HDLTC_RISK_PROB",
        "TG_RISK_PROB",
        "HR_BPM"
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
    
    // PDF States
    @State private var pdfURL: URL?
    @State private var isSharing = false

    private let showBottomButtons: Bool
    private let showLoadingOverlay: Bool
    private let showHeaderEmailButton: Bool
    
    public init(
        model: ResultsModel = ResultsModel(),
        result: [String: MeasurementResults.SignalResult] = [:],
        showBottomButtons: Bool = true,
        showLoadingOverlay: Bool = true,
        showHeaderEmailButton: Bool = true
    ) {
        _model = StateObject(wrappedValue: model)
        self.result = result
        self.showBottomButtons = showBottomButtons
        self.showLoadingOverlay = showLoadingOverlay
        self.showHeaderEmailButton = showHeaderEmailButton
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                mainContentView // Extracted for reuse in PDF
                    .padding(.bottom, showBottomButtons ? 150.h : 0)
            }
            .ignoresSafeArea(edges: .top)
            
            if showBottomButtons {
                ResultScreenButtons(result: result, onDownloadPDF: {
                    exportToPDF()
                })
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .screenDidChangeBounds)) { _ in
            refreshTrigger.toggle()
        }
        .sheet(isPresented: $isSharing) {
            if let url = pdfURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    // Extracted content view so we can render it without the ScrollView wrapper for PDF
    private var mainContentView: some View {
        VStack(spacing: 0) {
            HeroHeader(result: result, showsEmailButton: showHeaderEmailButton)
            TitleBlock()
            ResultsList(model: model)
        }
        .frame(maxWidth: .infinity)
        .background(Color(AppColors.systemBackground))
    }
    
    private func exportToPDF() {
        // We render the raw content (without the ScrollView) to ensure we get the full length
        let pdfView = mainContentView.frame(width: 595) // Fix width to A4
        
        if let url = PDFGenerator.generatePDF(view: pdfView, fileName: ResultScreenStrings.pdfFileName) {
            self.pdfURL = url
            self.isSharing = true
        }
    }
}

// MARK: - Subviews
private struct HeroHeader: View {
    let result: [String: MeasurementResults.SignalResult]
    let showsEmailButton: Bool

    private let title = ResultScreenStrings.heroTitle

    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                ResultToolbar()
                Spacer(minLength: 20)

                HStack(alignment: .center, spacing: 28.w) {
                    VStack(alignment: .leading, spacing: 8.h) {
                        buildSemiBoldText(title, 40.sp, color: Color(AppColors.primary))
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color(AppColors.white))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(ResultScreenStrings.heroDescription)
                            .foregroundColor(Color(AppColors.bodyTextMuted))
                            .font(.system(size: 20.sp, weight: .light))
                            .italic()
                    }

                    Spacer(minLength: 18.w)

                    if showsEmailButton {
                        ResultEmailButton(result: result)
                    }
                }
                .padding(.leading, 50.w)
                .padding(.trailing, 34.w)
                .padding(.top, 50.w)
                .padding(.bottom, 24.w)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ResultEmailButton: View {
    let result: [String: MeasurementResults.SignalResult]

    @State private var showEmailPopUp = false
    @State private var isEmailSent = false
    private let buttonColor = Color(AppColors.resultTitleText)

    var body: some View {
        Button {
            isEmailSent = false
            showEmailPopUp = true
        } label: {
            HStack(spacing: 16.w) {
                Image(AppIconNames.Asset.email)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24.w, height: 24.h)
                    .foregroundColor(buttonColor)

                Text(ResultScreenStrings.Actions.emailResults)
                    .font(.system(size: 20.sp, weight: .semibold))
                    .foregroundColor(buttonColor)
            }
            .frame(width: 270.w)
            .frame(minHeight: 72.h)
            .background(Color(AppColors.white))
            .overlay(
                RoundedRectangle(cornerRadius: 12.r, style: .continuous)
                    .stroke(buttonColor, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12.r, style: .continuous))
        }
        .fullScreenCover(isPresented: $showEmailPopUp, onDismiss: {
            isEmailSent = false
        }) {
            ResultPromptOverlay(layout: isEmailSent ? .emailSuccess : .emailEntry) {
                EmailResultPopup(
                    results: result,
                    isEmailSent: $isEmailSent
                )
            }
            .presentationBackground(Color.clear)
        }
    }
}

private struct TitleBlock: View {
    private var titleBlockDescription: String {
        ResultScreenStrings.titleBlockDescription
    }

    var body: some View {
        buildMediumText(
            titleBlockDescription,
            18.sp,
            color: Color(AppColors.primary)
        )
        .italic()
        .lineSpacing(8.h)
        .padding(.horizontal, 28.w)
        .padding(.vertical, 22.h)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemGray6))
        .overlay(
            RoundedRectangle(cornerRadius: 10.r, style: .continuous)
                .stroke(Color(AppColors.formBorder), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10.r, style: .continuous))
        .padding(.horizontal, 18.w)
        .padding(.vertical, 16.h)
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
