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
    @State private var guideStage: ResultGuideStage?
    @State private var hasScheduledGuideReveal = false

    private let showBottomButtons: Bool
    private let showLoadingOverlay: Bool
    private let showGuide: Bool
    
    public init(
        model: ResultsModel = ResultsModel(),
        result: [String: MeasurementResults.SignalResult] = [:],
        showBottomButtons: Bool = true,
        showLoadingOverlay: Bool = true,
        showGuide: Bool = true
    ) {
        _model = StateObject(wrappedValue: model)
        self.result = result
        self.showBottomButtons = showBottomButtons
        self.showLoadingOverlay = showLoadingOverlay
        self.showGuide = showGuide
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

            if showGuide, let guideStage {
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
        .onAppear {
            scheduleGuideRevealIfNeeded()
        }
        .onChange(of: model.results.count) { _, _ in
            scheduleGuideRevealIfNeeded()
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

    private func scheduleGuideRevealIfNeeded() {
        guard showGuide, guideStage == nil, hasScheduledGuideReveal == false else { return }
        guard model.results.isEmpty == false || result.isEmpty == false else { return }

        hasScheduledGuideReveal = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            guard guideStage == nil else { return }
            withAnimation(.spring(response: 0.36, dampingFraction: 0.86)) {
                guideStage = .bubble
            }
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
    var body: some View {
        buildMediumText(
            ResultScreenStrings.titleBlockDescription,
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
    let iconAsset: String
    let title: String
    let body: AttributedString
}

private struct ResultGuideOverlay: View {
    let stage: ResultGuideStage
    let onStageChange: (ResultGuideStage?) -> Void
    @State private var bubbleCenter: CGPoint?
    @State private var dragStartCenter: CGPoint?

    private let bubbleDiameter: CGFloat = 138.w
    private let horizontalPadding: CGFloat = 24.w
    private let bottomPadding: CGFloat = 275.h

    var body: some View {
        GeometryReader { proxy in
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

                if stage == .bubble {
                    ResultGuideBubble {
                        onStageChange(.firstMessage)
                    }
                    .frame(width: bubbleDiameter, height: bubbleDiameter)
                    .position(currentBubbleCenter(in: proxy.size))
                    .gesture(
                        DragGesture(minimumDistance: 1)
                            .onChanged { value in
                                if dragStartCenter == nil {
                                    dragStartCenter = currentBubbleCenter(in: proxy.size)
                                }

                                guard let dragStartCenter else { return }
                                bubbleCenter = clampedBubbleCenter(
                                    CGPoint(
                                        x: dragStartCenter.x + value.translation.width,
                                        y: dragStartCenter.y + value.translation.height
                                    ),
                                    in: proxy.size
                                )
                            }
                            .onEnded { _ in
                                let currentCenter = currentBubbleCenter(in: proxy.size)
                                let snappedX = currentCenter.x < proxy.size.width / 2
                                    ? horizontalPadding + bubbleDiameter / 2
                                    : proxy.size.width - horizontalPadding - bubbleDiameter / 2

                                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                                    bubbleCenter = clampedBubbleCenter(
                                        CGPoint(x: snappedX, y: currentCenter.y),
                                        in: proxy.size
                                    )
                                }
                                dragStartCenter = nil
                            }
                    )
                    .onAppear {
                        if bubbleCenter == nil {
                            bubbleCenter = defaultBubbleCenter(in: proxy.size)
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.94)))
                }
            }
        }
        .animation(.spring(response: 0.36, dampingFraction: 0.86), value: stage)
    }

    private func currentBubbleCenter(in size: CGSize) -> CGPoint {
        bubbleCenter.map { clampedBubbleCenter($0, in: size) } ?? defaultBubbleCenter(in: size)
    }

    private func defaultBubbleCenter(in size: CGSize) -> CGPoint {
        clampedBubbleCenter(
            CGPoint(
                x: size.width - horizontalPadding - bubbleDiameter / 2,
                y: size.height - bottomPadding - bubbleDiameter / 2
            ),
            in: size
        )
    }

    private func clampedBubbleCenter(_ center: CGPoint, in size: CGSize) -> CGPoint {
        let minX = horizontalPadding + bubbleDiameter / 2
        let maxX = size.width - horizontalPadding - bubbleDiameter / 2
        let minY = bubbleDiameter / 2 + 20.h
        let maxY = size.height - bubbleDiameter / 2 - 20.h

        return CGPoint(
            x: min(max(center.x, minX), maxX),
            y: min(max(center.y, minY), maxY)
        )
    }
}

private struct ResultGuideBubble: View {
    let onTap: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(AppIconNames.Asset.hiby)
                .resizable()
                .scaledToFill()
                .frame(width: 138.w, height: 138.w)
                .clipShape(Circle())

            Text("2")
                .font(.system(size: 25.sp, weight: .bold))
                .foregroundColor(Color(AppColors.black))
                .frame(width: 48.w, height: 48.w)
                .background(Color(AppColors.ctaGreen))
                .clipShape(Circle())
                .offset(x: -4.w, y: -8.h)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
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
    
    private let cardWidth = 625.w
    private let cardHeight = 600.h

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: characterAlignment == .leading ? .bottomLeading : .bottomTrailing) {
                VStack(spacing: 0) {
                    Spacer(minLength: 120.h)

                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top) {
                            Image(content.iconAsset)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72.w, height: 72.w)

                            Spacer()

                            Text(content.page)
                                .font(.system(size: 20.sp, weight: .medium))
                                .foregroundColor(Color(AppColors.error))
                        }

                        buildBoldText(content.title, 21.sp, color: Color(AppColors.primary))
                            .padding(.top, 26.h)

                        Text(content.body)
                            .font(.system(size: 15.sp))
                            .foregroundColor(Color(AppColors.bodyText))
                            .lineSpacing(7.h)
                            .padding(.top, 12.h)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer(minLength: 20.h)

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
                    .padding(.horizontal, 32.w)
                    .padding(.top, 36.h)
                    .padding(.bottom, 24.h)
                    .frame(width: min(proxy.size.width - 96.w, cardWidth))
                    .frame(height: cardHeight)
                    .background(Color(AppColors.white))
                    .clipShape(RoundedRectangle(cornerRadius: 22.r, style: .continuous))
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color(AppColors.primaryActionOrange))
                            .frame(height: 6.h)
                            .clipShape(RoundedCorner(radius: 22.r, corners: [.bottomLeft, .bottomRight]))
                    }
                    .shadow(color: Color(AppColors.black).opacity(0.18), radius: 24, x: 0, y: 16)

                    Spacer(minLength: 300.h)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Image(characterAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(proxy.size.width * 0.29, 330.w))
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
            .frame(minWidth: 128.w, minHeight: 46.h)
            .padding(.horizontal, 12.w)
            .background(style.background)
            .clipShape(RoundedRectangle(cornerRadius: 6.r, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private extension ResultGuideContent {
    static let first = ResultGuideContent(
        page: "1/2",
        iconAsset: AppIconNames.Asset.hibyMessageOne,
        title: ResultScreenStrings.Guide.firstTitle,
        body: ResultScreenStrings.Guide.firstBody
    )

    static let second = ResultGuideContent(
        page: "2/2",
        iconAsset: AppIconNames.Asset.hibyMessageTwo,
        title: ResultScreenStrings.Guide.secondTitle,
        body: ResultScreenStrings.Guide.secondBody
    )
}
