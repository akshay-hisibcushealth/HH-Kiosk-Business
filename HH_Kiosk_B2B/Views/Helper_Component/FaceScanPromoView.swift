import SwiftUI

struct FaceScanPromoView: View {
    @Binding var isNavigating: Bool

    var body: some View {
        ZStack {
            
            // Background Card
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#1C3F94"),
                            Color(hex: "#122C6A")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            HStack {
                
                // LEFT CONTENT
                VStack(alignment: .leading, spacing: 18) {
                    
                    Text("Stay on Top of Your Health")
                        .foregroundColor(.white.opacity(0.85))
                        .font(.system(size: 22, weight: .medium))
                    
                    Text("Try our 30 second Face Scan!")
                        .foregroundColor(.white)
                        .font(.system(size: 34, weight: .bold))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // CTA BUTTON
                    Button {
                        isNavigating = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "face.smiling")
                                .font(.system(size: 22, weight: .bold))
                            
                            Text("Start Face Scan")
                                .font(.system(size: 22, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .padding(.vertical, 18)
                        .padding(.horizontal, 28)
                        .background(
                            Capsule()
                                .fill(Color(hex: "#B6E34B"))
                        )
                    }
                    
                    // HOW IT WORKS
                    HStack(spacing: 8) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 22))
                        
                        Text("See how it works")
                            .foregroundColor(.yellow)
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .padding(.top, 6)
                    
                }
                .padding(.leading, 32)
                .padding(.vertical, 32)
                
                Spacer()
                
                // RIGHT IMAGE
                Image("face_scan_promo_model") // add image in Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .offset(x: 40, y: 10)
            }
        }
        .frame(height: 420)
        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 12)
    }
}
