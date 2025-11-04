import SwiftUI
struct SectionHeader: View {
    let title: String
    let isLeading: Bool
    var body: some View {
        HStack {
            if isLeading {
                Image("schedule")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48.w, height: 48.h)
                    .foregroundColor(Color(hex: "#241F1F"))
            }
            buildSemiBoldText(title, 28.sp,color: Color(hex: "#241F1F"))
            if !isLeading {
                Image(systemName: "chevron.right")
                    .font(.system(size: 24.sp))
                    .foregroundColor(Color(hex: "#241F1F"))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16.w) } }
