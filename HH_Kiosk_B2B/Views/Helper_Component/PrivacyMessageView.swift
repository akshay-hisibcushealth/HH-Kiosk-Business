import SwiftUI

struct PrivacyMessageView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            buildSemiBoldText("Your Face Scan Results",44.sp)
            .padding(.horizontal, 48)
            .padding(.top, 32)

            HStack(alignment: .center, spacing: 16) {
                Image(systemName: "info.circle")
                    .foregroundColor(Color(hex: "#246FA0"))
                    .font(.system(size: 24))
                    .alignmentGuide(.firstTextBaseline) { d in d[VerticalAlignment.top] }

                Text("The results from this face scan are not intended to diagnose, treat, or replace professional medical advice. For any health concerns, please consult a healthcare provider.")
                    .font(.system(size: 22.sp))
                    .italic()
                    .foregroundColor(Color(hex: "#246FA0"))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom,16.h)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "#DFEEF7"))
            .cornerRadius(8)
            .padding(.leading, 32)
            .padding(.trailing, 16)
            .padding(.top, 16)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
