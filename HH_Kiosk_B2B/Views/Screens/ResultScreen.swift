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
                })
                .background(Color.white)
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
        .background(Color(.systemBackground))
    }
    
    private func exportToPDF() {
        // We render the raw content (without the ScrollView) to ensure we get the full length
        let pdfView = mainContentView.frame(width: 595) // Fix width to A4
        
        if let url = PDFGenerator.generatePDF(view: pdfView, fileName: "Hibiscus_Health_Report") {
            self.pdfURL = url
            self.isSharing = true
        }
    }
}

// MARK: - Subviews
private struct HeroHeader: View {
    var body: some View {
        ZStack(alignment: .leading) {
            Image("result_screen_top_image")
                .resizable()
                .scaledToFill()
                .frame(height: 460.h)
                .clipped()
                .padding(.top, 200.h)
            
            VStack(alignment: .leading, spacing: 0) {
                ResultToolbar()
                Spacer(minLength: 20)
                buildSemiBoldText("Your Face Scan Results", 50.sp, color: Color(hex: "#142A6D"))
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.leading, 50.w)
                Text("This sample report features your personal face-scan results and demonstrates how we can design a customized, population-level version aligned with your wellness strategy — giving individuals insight and delivering actionable value for your organization.")
                    .foregroundColor(Color(hex: "#353535"))
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
                .fill(Color(hex: "#B8E2F5"))
                .frame(maxWidth: .infinity)
                .frame(height: 120.h)
            
            buildMediumText(
                "At Hibiscus, we believe that great technology is only meaningful when paired with thoughtful human support. Our facial-scan insights are designed to spark action and our programs ensure each member is guided, not left on their own, to achieve lasting health goals.",
                18.sp,
                color: Color(hex: "#142A6D")
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
                .fill(Color(hex: "#FFE7DE"))
                .overlay(
                    RoundedRectangle(cornerRadius: 8.r, style: .continuous)
                        .stroke(Color(hex: "A92E00"), lineWidth: 1)
                )
                .frame(maxWidth: .infinity)
                .frame(minHeight: 105.h, maxHeight: 105.h)
            
            HStack(spacing: 12.w) {
                Image(systemName: "info.circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(hex: "A92E00"))
                    .padding(.leading, 12.w)
                
                Text("Hibiscus Health is intended to improve your awareness of general wellness. Hibiscus Health does not diagnose, treat, mitigate or prevent any disease, symptom, disorder or abnormal physical state. Consult with a healthcare professional or emergency services if you believe you may have a medical issue.")
                    .font(.system(size: 18.sp))
                    .foregroundColor(Color(hex: "8A2600"))
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
                Color(hex: "#142A6D")
                    .frame(height: 100.h)
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(edges: .bottom)
                Image("result_screen_bottom_image")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 600.h)
                    .clipShape(
                        RoundedCorner(radius: 40.r, corners: [.topLeft, .topRight])
                    )

                VStack {
                    buildMediumText("Next Steps", 44.sp, color: .white)
                    VStack(alignment: .leading, spacing: 8) {
                        (
                            Text("We know every organization is unique. Whether you’re an employer, health plan, or solution partner, Hibiscus can integrate seamlessly into your existing ecosystem — or provide full end-to-end support from ")
                            + Text("Face Scan → Care Guide → Clinician").fontWeight(.bold)
                            + Text(" for maximum impact. Choose the components that best complement your current resources.")
                        )
                        .font(.system(size: 19.sp))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.bottom, 24.h)
                    .padding(.horizontal, 150.w)
                    
                    Image("bottom_info_box")
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
    private let appStoreURL = URL(string: "https://apps.apple.com/tn/app/hibiscus-health/id6478411080")!
    private let playStoreURL = URL(string: "https://play.google.com/store/apps/details?id=com.nutritionApp.hibiscus_health&hl")!
    
    var body: some View {
        VStack(spacing: 32.h) {
            VStack(spacing: 0) {
                buildMediumText("Find even more resources,", 44.sp, color: .white, alignment: .center)
                buildMediumText("tips & insights on the app", 44.sp, color: .white, alignment: .center)
            }
            .padding(.top, 16.h)
            
            HStack(spacing: 48.w) {
                Link(destination: appStoreURL) {
                    Image("app_store_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180.w)
                }
                
                Link(destination: playStoreURL) {
                    Image("play_store_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180.w)
                }
            }
            Image("powered_by_hh_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 220.w, height: 140.h)
                .padding(.vertical, 16.h)
                .padding(.trailing, 32.h)
            Text("575 LEXINGTON AVE, FL 14TH NEW YORK, NY 10022-6102 United States")
                .font(.system(size: 20.sp))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 8.h)
        }
        .padding(.vertical, 48.h)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#142A6D"))
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
