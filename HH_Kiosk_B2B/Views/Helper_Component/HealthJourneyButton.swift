import SwiftUI

struct HealthJourneyButton: View {
    @EnvironmentObject var appState: AppState
    // MARK: - Parameters with default values
    var text: String = "Start Your Health Journey."
    var backgroundColor: Color = Color(red: 0.85, green: 0.23, blue: 0.0)
    var textColor: Color = .white
    var icon: String = "scan_face"
    
    var body: some View {
            Button(action: {
                withAnimation {
                      appState.showScreenSaver = false
                  }
            }) {
                HStack {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48.w, height: 48.h)
                        .foregroundColor(textColor)
                        .padding(.leading, 64.w)
                        .padding(.trailing, 32.w)
                    
                    Text(text)
                        .font(.system(size: 32.sp, weight: .semibold))
                        .foregroundColor(textColor)
                        .padding(.trailing, 64.w)
                }
                .padding(.vertical, 20.h)
                .background(backgroundColor)
                .cornerRadius(200.r)
            }
            .buttonStyle(.plain)
            
        
    }
}
