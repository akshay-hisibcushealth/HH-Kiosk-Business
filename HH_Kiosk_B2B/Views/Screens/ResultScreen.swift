import SwiftUI
import Combine
import AnuraCore

// MARK: - Models
public struct SignalResult: Decodable {
    public let notes: [String]
    public let value: Double
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
        "TG_RISK_PROB"
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
    
    public init(
        model: ResultsModel = ResultsModel(),
        result: [String: MeasurementResults.SignalResult] = [:],
        showBottomButtons: Bool = true,
        showLoadingOverlay: Bool = true
    ) {
        _model = StateObject(wrappedValue: model)
        self.result = result
        self.showBottomButtons = showBottomButtons
        self.showLoadingOverlay = showLoadingOverlay
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                mainContentView // Extracted for reuse in PDF
            }
            .ignoresSafeArea(edges: .top)
            
            if showBottomButtons {
                ResultScreenButtons(result: result, onDownloadPDF: {
                    exportToPDF()
                },onPrint: {})
                .background(Color(AppColors.white))
                .shadow(radius: 4)
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
            HeroHeader()
            TitleBlock()
            ResultsList(model: model)
            BottomBar()
            Footer()
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
    var body: some View {
        ZStack(alignment: .leading) {
            Image(AppIconNames.Asset.resultScreenTopImage)
                .resizable()
                .scaledToFill()
                .frame(height: 460.h)
                .clipped()
                .padding(.top, 200.h)
            
            VStack(alignment: .leading, spacing: 0) {
                ResultToolbar()
                Spacer(minLength: 20)
                buildSemiBoldText(ResultScreenStrings.title, 50.sp, color: Color(AppColors.primary))
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color(AppColors.white))
                    .padding(.leading, 50.w)
                Text(ResultScreenStrings.heroDescription)
                    .foregroundColor(Color(AppColors.bodyTextMuted))
                    .font(.system(size: 24.sp, weight: .light))
                    .italic()
                    .padding(.leading, 50.w)
                    .padding(.bottom, 24.w)
                    .padding(.trailing, 330.w)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct TitleBlock: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(AppColors.resultInfoBackground))
                .frame(maxWidth: .infinity)
                .frame(height: 120.h)
            
            buildMediumText(
                ResultScreenStrings.titleBlockDescription,
                18.sp,
                color: Color(AppColors.primary)
            )
            .padding(.leading, 48.w)
            .padding(.trailing, 120.w)
        }
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

private struct BottomBar: View {
    var body: some View {
        VStack(spacing: 16.h) {
            InfoFooter()
                .padding(.horizontal, 24.w)
                .padding(.bottom, 40.h)
            ZStack(alignment: .bottom) {
                Color(AppColors.primary)
                    .frame(height: 100.h)
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(edges: .bottom)
                Image(AppIconNames.Asset.resultScreenBottomImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 600.h)
                    .clipShape(
                        RoundedCorner(radius: 40.r, corners: [.topLeft, .topRight])
                    )

                VStack {
                    buildMediumText(ResultScreenStrings.nextStepsTitle, 44.sp, color: Color(AppColors.white))
                    VStack(alignment: .leading, spacing: 8) {
                        (
                            Text(ResultScreenStrings.nextStepsPrefix)
                            + Text(ResultScreenStrings.nextStepsEmphasis).fontWeight(.bold)
                            + Text(ResultScreenStrings.nextStepsSuffix)
                        )
                        .font(.system(size: 19.sp))
                        .foregroundColor(Color(AppColors.white))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.bottom, 24.h)
                    .padding(.horizontal, 150.w)
                    
                    Image(AppIconNames.Asset.bottomInfoBox)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 400.h)
                        .clipped()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct Footer: View {
    private let appStoreURL = URL(string: ResultScreenStrings.appStoreURL)!
    private let playStoreURL = URL(string: ResultScreenStrings.playStoreURL)!
    
    var body: some View {
        VStack(spacing: 32.h) {
                buildMediumText(ResultScreenStrings.footerResources, 44.sp, color: Color(AppColors.white), alignment: .center)
            
            
            HStack(spacing: 48.w) {
                Link(destination: appStoreURL) {
                    Image(AppIconNames.Asset.appStoreButton)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180.w)
                }
                
                Link(destination: playStoreURL) {
                    Image(AppIconNames.Asset.playStoreButton)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180.w)
                }
            }
            .padding(.bottom, 24.h)
            Image(AppIconNames.Asset.poweredByHHLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 220.w, height: 140.h)
                .padding(.vertical, 16.h)
                .padding(.trailing, 32.h)
            Text(ResultScreenStrings.footerAddress)
                .font(.system(size: 20.sp))
                .foregroundColor(Color(AppColors.white))
                .multilineTextAlignment(.center)
                .padding(.top, 8.h)
        }
        .padding(.vertical, 48.h)
        .frame(maxWidth: .infinity)
        .background(Color(AppColors.primary))
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
