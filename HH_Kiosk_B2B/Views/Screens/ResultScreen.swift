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
    @State private var guideStage: ResultGuideStage? = .bubble

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
        ZStack {
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

            if let guideStage {
                ResultGuideOverlay(stage: guideStage) { nextStage in
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.86)) {
                        self.guideStage = nextStage
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                .zIndex(2)
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
     VStack(alignment: .leading, spacing: 0) {
                ResultToolbar()
                Spacer(minLength: 20)
                buildSemiBoldText(ResultScreenStrings.title, 40.sp, color: Color(AppColors.primary))
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color(AppColors.white))
                    .padding(.leading, 50.w)
                    .padding(.top, 50.w)
                Text(ResultScreenStrings.heroDescription)
                    .foregroundColor(Color(AppColors.bodyTextMuted))
                    .font(.system(size: 20.sp, weight: .light))
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
    @EnvironmentObject private var appState: AppState

    private var titleBlockDescription: String {
        let brandingDescription = appState.brandingData?.brandingInfo.resultScreenDescription?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let brandingDescription, !brandingDescription.isEmpty {
            return brandingDescription
        }

        return ResultScreenStrings.titleBlockDescription
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

private enum ResultGuideStage {
    case bubble
    case firstMessage
    case secondMessage
}

private struct ResultGuideContent {
    let page: String
    let iconName: String
    let title: String
    let body: AttributedString
}

private struct ResultGuideOverlay: View {
    let stage: ResultGuideStage
    let onStageChange: (ResultGuideStage?) -> Void
    @State private var bubbleOffset: CGSize = .zero
    @GestureState private var bubbleDragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            if stage != .bubble {
                Color(AppColors.primary)
                    .opacity(0.66)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            if stage != .bubble {
                switch stage {
                case .bubble:
                    EmptyView()
                case .firstMessage:
                    ResultGuideModal(
                        content: .first,
                        characterAsset: AppIconNames.Asset.hibyLeft,
                        characterAlignment: .leading,
                        showsBackButton: false,
                        onBack: {},
                        onNext: { onStageChange(.secondMessage) },
                        onClose: { onStageChange(.bubble) }
                    )
                case .secondMessage:
                    ResultGuideModal(
                        content: .second,
                        characterAsset: AppIconNames.Asset.hibyRight,
                        characterAlignment: .trailing,
                        showsBackButton: true,
                        onBack: { onStageChange(.firstMessage) },
                        onNext: {},
                        onClose: { onStageChange(.bubble) }
                    )
                }
            }

            ResultGuideBubble(
                offset: CGSize(
                    width: bubbleOffset.width + bubbleDragOffset.width,
                    height: bubbleOffset.height + bubbleDragOffset.height
                ),
                onTap: {
                    onStageChange(.firstMessage)
                }
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($bubbleDragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        bubbleOffset.width += value.translation.width
                        bubbleOffset.height += value.translation.height
                    }
            )
        }
        .animation(.spring(response: 0.36, dampingFraction: 0.86), value: stage)
    }
}

private struct ResultGuideBubble: View {
    let offset: CGSize
    let onTap: () -> Void

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: onTap) {
                    ZStack(alignment: .topLeading) {
                        Image(AppIconNames.Asset.hiby)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 138.w, height: 138.w)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(AppColors.primary), lineWidth: 6.w)
                            )
                            .shadow(color: Color(AppColors.black).opacity(0.26), radius: 18, x: 0, y: 8)

                        Text("2")
                            .font(.system(size: 25.sp, weight: .bold))
                            .foregroundColor(Color(AppColors.black))
                            .frame(width: 48.w, height: 48.w)
                            .background(Color(AppColors.ctaGreen))
                            .clipShape(Circle())
                            .offset(x: -4.w, y: -8.h)
                    }
                }
                .buttonStyle(.plain)
                .padding(.trailing, 24.w)
                .padding(.bottom, 275.h)
                .offset(offset)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

private struct ResultGuideModal: View {
    let content: ResultGuideContent
    let characterAsset: String
    let characterAlignment: HorizontalAlignment
    let showsBackButton: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    let onClose: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: characterAlignment == .leading ? .bottomLeading : .bottomTrailing) {
                VStack(spacing: 0) {
                    Spacer(minLength: 84.h)

                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top) {
                            Image(systemName: content.iconName)
                                .font(.system(size: 62.sp, weight: .regular))
                                .foregroundColor(Color(AppColors.primary))
                                .frame(width: 82.w, height: 82.w)

                            Spacer()

                            Text(content.page)
                                .font(.system(size: 24.sp, weight: .medium))
                                .foregroundColor(Color(AppColors.error))
                        }

                        buildBoldText(content.title, 24.sp, color: Color(AppColors.primary))
                            .padding(.top, 22.h)

                        Text(content.body)
                            .font(.system(size: 18.sp))
                            .foregroundColor(Color(AppColors.bodyText))
                            .lineSpacing(9.h)
                            .padding(.top, 14.h)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer(minLength: 24.h)

                        HStack(spacing: 16.w) {
                            Spacer()

                            if showsBackButton {
                                ResultGuideActionButton(
                                    title: ResultScreenStrings.Guide.back,
                                    systemImage: "arrow.left",
                                    style: .secondary,
                                    imagePlacement: .leading,
                                    action: onBack
                                )
                            }

                            if showsBackButton {
                                ResultGuideActionButton(
                                    title: ResultScreenStrings.Guide.close,
                                    systemImage: "arrow.right",
                                    style: .destructive,
                                    imagePlacement: .trailing,
                                    action: onClose
                                )
                            } else {
                                ResultGuideActionButton(
                                    title: ResultScreenStrings.Guide.next,
                                    systemImage: "arrow.right",
                                    style: .secondary,
                                    imagePlacement: .trailing,
                                    action: onNext
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 38.w)
                    .padding(.top, 48.h)
                    .padding(.bottom, 30.h)
                    .frame(width: min(proxy.size.width * 0.58, 610.w))
                    .frame(minHeight: 510.h)
                    .background(Color(AppColors.white))
                    .clipShape(RoundedRectangle(cornerRadius: 28.r, style: .continuous))
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color(AppColors.primaryActionOrange))
                            .frame(height: 7.h)
                            .clipShape(RoundedCorner(radius: 28.r, corners: [.bottomLeft, .bottomRight]))
                    }
                    .shadow(color: Color(AppColors.black).opacity(0.18), radius: 24, x: 0, y: 16)

                    Spacer(minLength: 260.h)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Image(characterAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(proxy.size.width * 0.32, 360.w))
                    .padding(.leading, characterAlignment == .leading ? 44.w : 0)
                    .padding(.trailing, characterAlignment == .trailing ? 44.w : 0)
                    .offset(y: 34.h)
                    .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

private enum ResultGuideButtonStyle {
    case secondary
    case destructive

    var background: Color {
        switch self {
        case .secondary:
            return Color(AppColors.resultInfoBackground)
        case .destructive:
            return Color(AppColors.resultAlertBackground)
        }
    }

    var foreground: Color {
        switch self {
        case .secondary:
            return Color(AppColors.primary)
        case .destructive:
            return Color(AppColors.primaryActionOrange)
        }
    }
}

private enum ResultGuideImagePlacement {
    case leading
    case trailing
}

private struct ResultGuideActionButton: View {
    let title: String
    let systemImage: String
    let style: ResultGuideButtonStyle
    let imagePlacement: ResultGuideImagePlacement
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10.w) {
                if imagePlacement == .leading {
                    Image(systemName: systemImage)
                }

                Text(title)
                    .font(.system(size: 16.sp, weight: .bold))

                if imagePlacement == .trailing {
                    Image(systemName: systemImage)
                }
            }
            .foregroundColor(style.foreground)
            .frame(minWidth: 150.w, minHeight: 54.h)
            .padding(.horizontal, 14.w)
            .background(style.background)
            .clipShape(RoundedRectangle(cornerRadius: 6.r, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private extension ResultGuideContent {
    static let first = ResultGuideContent(
        page: "1/2",
        iconName: "doc.text.image",
        title: ResultScreenStrings.Guide.firstTitle,
        body: ResultScreenStrings.Guide.firstBody
    )

    static let second = ResultGuideContent(
        page: "2/2",
        iconName: "chart.line.uptrend.xyaxis.circle",
        title: ResultScreenStrings.Guide.secondTitle,
        body: ResultScreenStrings.Guide.secondBody
    )
}
