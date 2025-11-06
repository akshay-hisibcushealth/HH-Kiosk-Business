// ResultScreen.swift
// SwiftUI single-screen result view (self-contained)
// Minor changes: takes injected ResultsModel, and flags to hide bottom buttons / loading overlay.
// BottomButtons exposes closure callbacks so UIKit can hook them.

import SwiftUI
import Combine

// -----------------------------
// Models (simple, local copy)
// -----------------------------
public struct SignalResult: Decodable {
    public let notes: [String]
    public let value: Double
}

public typealias ResultsMap = [String: SignalResult]

public final class ResultsModel: ObservableObject {
    @Published public var results: ResultsMap = [:]
    @Published public var isLoading: Bool = false
    
    public init(loadMock: Bool = true) {
        if loadMock { loadMockData() }
    }
    
    public func loadMockData() {
        isLoading = true
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let jsonString = """
            { "BP_CVD" : { "notes" : [ ], "value" : 0.2024 }, "BP_SYSTOLIC" : { "notes" : [ ], "value" : 112.4425 }, "BP_DIASTOLIC" : { "notes" : [ ], "value" : 83.7584 }, "HBA1C_RISK_PROB" : { "notes" : [ ], "value" : 26.295 }, "HDLTC_RISK_PROB" : { "notes" : [ ], "value" : 54.1508 }, "TG_RISK_PROB" : { "notes" : [ ], "value" : 47.1745 }, "HR_BPM" : { "notes" : [ ], "value" : 70.4494 } }
            """
            let data = Data(jsonString.utf8)
            let decoded = (try? JSONDecoder().decode(ResultsMap.self, from: data)) ?? [:]
            DispatchQueue.main.async {
                self.results = decoded
                self.isLoading = false
            }
        }
    }
}

// -----------------------------
// Main Screen (single top-level view)
// -----------------------------
public struct ResultScreen: View {
    @StateObject private var model: ResultsModel
    
    private let showBottomButtons: Bool
    private let showLoadingOverlay: Bool
    
    public init(model: ResultsModel = ResultsModel(),
                showBottomButtons: Bool = true,
                showLoadingOverlay: Bool = true) {
        _model = StateObject(wrappedValue: model)
        self.showBottomButtons = showBottomButtons
        self.showLoadingOverlay = showLoadingOverlay
    }
    
    // define the list of rows we want to show and ranges
    private let rows: [(key: String, title: String, min: Double, max: Double, unit: String)] = [
        ("BP_CVD", "Cardiovascular Disease Risk", 0, 1, "%"),
        ("BP_SYSTOLIC", "Systolic Blood Pressure", 0, 180, "mmHg"),
        ("BP_DIASTOLIC", "Diastolic Blood Pressure", 0, 120, "mmHg"),
        ("HBA1C_RISK_PROB", "Hemoglobin A1C Risk", 0, 100, "%"),
        ("HDLTC_RISK_PROB", "Hypercholesterolemia Risk", 0, 100, "%"),
        ("TG_RISK_PROB", "Hypertriglyceridemia Risk", 0, 100, "%"),
        ("HR_BPM", "Heart Rate", 0, 140, "bpm")
    ]
    
    public var body: some View {
        ZStack {
            // scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(spacing: 0) {
                        // top toolbar / hero
                        HeroHeader()
                        TitleBlock()
                        
                        ForEach(rows, id: \.key) { r in
                            ResultRowView(
                                title: r.title,
                                discription: "Some description",
                                rawValue: model.results[r.key]?.value,
                                minValue: r.min,
                                maxValue: r.max,
                                unit: r.unit
                            )
                            .padding(.horizontal, 18)
                        }
                        
                        InfoFooter()
                            .padding(.horizontal, 18)
                            .padding(.top, 8)
                        
                        NextStepsCard()
                            .padding(.horizontal, 18)
                            .padding(.top, 16)
                        
                        Spacer(minLength: 80) // give room before bottom buttons
                    }
                    .padding(.vertical, 10)
                } // ScrollView
                .background(Color(.systemBackground))
            } // VStack
            
            // Bottom fixed buttons (only if requested)
            if showBottomButtons {
                VStack {
                    Spacer()
                    BottomButtons() // default actions are internal no-ops for pure SwiftUI usage
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            
            // Loading overlay (only if requested)
            if showLoadingOverlay && model.isLoading {
                LoadingOverlay()
            }
        } // ZStack
        .onAppear { /* nothing extra yet; model loads mock by default if created with mock flag */ }
    }
}

// -----------------------------
// Subviews (all inside same file)
// -----------------------------
private struct HeroHeader: View {
    var body: some View {
        ZStack(alignment: .leading) {
            Image("result_screen_top_image")
                .resizable()
                .frame(width: Screen.width,height: Screen.height*0.3)
                .scaledToFit()
            
            VStack(alignment: .leading, spacing:0) {
                ResultToolbar()
                Spacer()
                buildSemiBoldText("Your Face Scan Results",50.sp,color: Color(hex: "#142A6D"))
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.leading,50.w)
                Text("This sample report features your personal face-scan results and demonstrates how we can design a customized, population-level version aligned with your wellness strategy — giving individuals insight and delivering actionable value for your organization.")
                    .foregroundColor(Color(hex: "#353535"))
                    .font(.system(size: 22.sp,weight: .light))
                    .italic()
                    .padding(.leading,50.w)
                    .padding(.bottom,24.w)
                    .padding(.trailing,300.w)

            }
        }
    }
}


private struct TitleBlock: View {
    var body: some View {
        ZStack{  Rectangle()
                .fill(Color(hex: "#B8E2F5"))
                .frame(height: 120.h)
            buildMediumText("At Hibiscus, we believe that great technology is only meaningful when paired with thoughtful human support. Our facial-scan insights are designed to spark action and our programs ensure each member is guided, not left on their own, to achieve lasting health goals.",18.sp,color: Color(hex: "#142A6D"))
                .padding(.vertical,12.h)
                .padding(.leading,38.w)
                .padding(.trailing,150.w)
            
            
        }}
}

private struct ResultRowView: View {
    let title: String
    let discription: String
    let rawValue: Double?
    let minValue: Double
    let maxValue: Double
    let unit: String
    
    private var progress: Double {
        guard let v = rawValue else { return 0 }
        let scaled = (v - minValue) / max(0.00001, (maxValue - minValue))
        return min(1, max(0, scaled))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(red: 15/255, green: 46/255, blue: 86/255))
            
            Text(discription)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(red: 15/255, green: 46/255, blue: 86/255))
            
            HStack(alignment: .center, spacing: 12) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 14)
                    
                    GeometryReader { g in
                        let w = g.size.width
                        HStack(spacing: 0) {
                            Rectangle().fill(Color.green).frame(width: w * 0.35)
                            Rectangle().fill(Color.yellow).frame(width: w * 0.18)
                            Rectangle().fill(Color.orange).frame(width: w * 0.23)
                            Rectangle().fill(Color.red).frame(width: w * 0.24)
                        }
                        .mask(Capsule())
                        .frame(height: 14)
                        
                        let indicatorX = CGFloat(progress) * w
                        Triangle()
                            .fill(Color(white: 0.15))
                            .frame(width: 12, height: 8)
                            .offset(x: max(0, min(w - 12, indicatorX - 6)), y: -10)
                    }
                    .frame(height: 14)
                }
                .frame(height: 24)
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .trailing) {
                    if let v = rawValue {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(formatted(value: v, unit: unit))
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color(red: 19/255, green: 85/255, blue: 44/255))
                        }
                    } else {
                        Text("--")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 110)
            }
            
            HStack {
                Text(statusText)
                    .font(.system(size: 12))
                    .foregroundColor(statusColor)
                    .lineLimit(3)
                Spacer()
            }
            .padding(.top, 4)
            
            Divider()
                .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
    
    private var statusText: String {
        guard let v = rawValue else { return "No result available." }
        let valueForLogic = (unit == "%" && maxValue <= 1) ? v * 100 : v
        if valueForLogic < 20 { return "Your results indicate that you have a low risk." }
        if valueForLogic < 50 { return "Your results indicate there is a medium risk." }
        return "Your results indicate that you are at a high risk."
    }
    
    private var statusColor: Color {
        guard let v = rawValue else { return .secondary }
        let valueForLogic = (unit == "%" && maxValue <= 1) ? v * 100 : v
        if valueForLogic < 20 { return Color.green }
        if valueForLogic < 50 { return Color.orange }
        return Color.red
    }
    
    private func formatted(value: Double, unit: String) -> String {
        if unit == "%" && maxValue <= 1 {
            return String(format: "%.2f %%", value * 100)
        }
        if abs(value - round(value)) < 0.01 {
            return String(format: "%.0f %@", value, unit)
        } else {
            return String(format: "%.2f %@", value, unit)
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

private struct InfoFooter: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hibiscus Health is intended to improve your awareness of general wellness. Hibiscus Health does not diagnose, treat, mitigate or prevent any disease, symptom, disorder or abnormal physical state. Consult with a healthcare professional or emergency services if you believe you may have a medical issue.")
                .font(.system(size: 12))
                .foregroundColor(Color(red: 120/255, green: 120/255, blue: 120/255))
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(red: 255/255, green: 245/255, blue: 244/255)))
        }
    }
}

private struct NextStepsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Next Steps")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .padding(.bottom, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.white)
                        .frame(width: 28)
                    VStack(alignment: .leading) {
                        Text("Guided by the Hibiscus Care Guide")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Text("A dedicated Hibiscus Care Guide can review each user's results and guide next steps.")
                            .font(.system(size: 12))
                            .foregroundColor(Color.white.opacity(0.9))
                    }
                }
                HStack(alignment: .top) {
                    Image(systemName: "link")
                        .foregroundColor(.white)
                        .frame(width: 28)
                    VStack(alignment: .leading) {
                        Text("Integrated With Your Ecosystem")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Hibiscus amplifies engagement and smooths transitions into your current programs.")
                            .font(.system(size: 12))
                            .foregroundColor(Color.white.opacity(0.9))
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.08)))
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 24/255, green: 66/255, blue: 121/255), Color(red: 12/255, green: 43/255, blue: 98/255)]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(12)
    }
}

// BottomButtons now exposes callbacks for UIKit integration
public struct BottomButtons: View {
    public var closeAction: (() -> Void)?
    public var emailAction: (() -> Void)?
    
    public init(closeAction: (() -> Void)? = nil, emailAction: (() -> Void)? = nil) {
        self.closeAction = closeAction
        self.emailAction = emailAction
    }
    
    @State private var emailed = false
    
    public var body: some View {
        HStack(spacing: 12) {
            Button(action: { closeAction?() }) {
                Text("Close result")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(white: 0.9)))
            }
            
            Button(action: {
                emailed.toggle()
                emailAction?()
            }) {
                HStack {
                    Image(systemName: "envelope.fill")
                    Text("Email my results")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(red: 188/255, green: 226/255, blue: 140/255)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(VisualEffectView(material: .systemMaterial, blendingMode: .systemMaterial).opacity(0.02))
    }
}

// simple loading overlay
private struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.25).edgesIgnoringSafeArea(.all)
            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.6)
                Text("Loading...")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.45)))
        }
    }
}

// small wrapper for blur background (used for bottom area)
private struct VisualEffectView: UIViewRepresentable {
    var material: UIBlurEffect.Style = .systemMaterial
    var blendingMode: UIBlurEffect.Style = .systemMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: material))
        return v
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// Optional toolbar / privacy placeholders (so the file compiles if you preview standalone)
public struct RToolbar: View {
    public init() {}
    public var body: some View {
        Rectangle()
            .fill(Color.blue)
            .overlay(HStack { Text("Toolbar").foregroundColor(.white); Spacer() }.padding())
    }
}
public struct RPrivacyMessageView: View {
    public init() {}
    public var body: some View {
        Rectangle()
            .fill(Color(.systemGray6))
            .overlay(Text("Privacy message").padding())
            .frame(height: 60)
    }
}
