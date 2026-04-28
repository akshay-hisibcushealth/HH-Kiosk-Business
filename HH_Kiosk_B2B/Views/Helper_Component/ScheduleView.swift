import SwiftUI

struct ScheduleView: View {
    var onInteraction: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24.h) {
            buildSemiBoldText(
                HomeScreenStrings.Schedule.sectionTitle,
                34.sp,
                color: Color(AppColors.resultAlertText)
            )
            .padding(.top, 28.h)
            .padding(.horizontal, 30.w)

            VStack(spacing: 24.h) {
                ForEach(HomeScreenStrings.Schedule.announcements, id: \.self) { announcement in
                    Text(announcement)
                        .font(.system(size: 20.sp, weight: .semibold))
                        .foregroundColor(Color(AppColors.resultAlertText))
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .frame(maxWidth: .infinity, minHeight: 72.h, alignment: .leading)
                        .padding(.horizontal, 24.w)
                        .padding(.vertical, 12.w)
                        .background(Color(AppColors.resultAlertBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8.r, style: .continuous))
                        .contentShape(RoundedRectangle(cornerRadius: 8.r, style: .continuous))
                        .onTapGesture {
                            onInteraction?()
                        }
                }
            }
            .padding(.horizontal, 24.w)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(AppColors.overlayMint))
        .clipShape(RoundedRectangle(cornerRadius: 24.r))
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onInteraction?() }
        )
    }
}
