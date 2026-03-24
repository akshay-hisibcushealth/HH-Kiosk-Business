import SwiftUI

struct PrivacyMessageView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            buildSemiBoldText(ResultScreenStrings.title,44.sp)
            .padding(.horizontal, 48)
            .padding(.top, 32)

            HStack(alignment: .center, spacing: 16) {
                Image(systemName: "info.circle")
                    .foregroundColor(Color(AppColors.supportLinkText))
                    .font(.system(size: 24))
                    .alignmentGuide(.firstTextBaseline) { d in d[VerticalAlignment.top] }

                Text(ResultScreenStrings.privacyMessage)
                    .font(.system(size: 22.sp))
                    .italic()
                    .foregroundColor(Color(AppColors.supportLinkText))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom,16.h)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(AppColors.infoPanelBackground))
            .cornerRadius(8)
            .padding(.leading, 32)
            .padding(.trailing, 16)
            .padding(.top, 16)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
