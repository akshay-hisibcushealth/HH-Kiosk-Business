import SwiftUI
struct SectionHeader: View {
    let title: String
    let isLeading: Bool
    var body: some View {
        HStack {
            if isLeading {
                Image(AppIconNames.Asset.schedule)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48.w, height: 48.h)
                    .foregroundColor(Color(AppColors.sectionHeaderText))
            }
            buildSemiBoldText(title, 28.sp,color: Color(AppColors.resultAlertText))
          
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16.w) } }
