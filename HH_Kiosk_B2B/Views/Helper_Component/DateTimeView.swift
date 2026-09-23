import SwiftUI

struct DateTimeView: View {
    var contentScale: CGFloat = 1

    @State private var currentDate = Date()
    @State private var timerStarted = false

    var body: some View {
        VStack(alignment: .trailing, spacing: contentScale == 1 ? nil : 8 * contentScale) {
            // First row: icon + time
            HStack(spacing: 8.w * contentScale) {
                Image(systemName: isDayTime ? AppIconNames.Symbol.sunMaxFill : AppIconNames.Symbol.moonFill)
                    .font(.system(size: 32.sp * contentScale))
                    .foregroundColor(Color(AppColors.secondary))

                Text(timeString)
                    .foregroundColor(Color(AppColors.secondary))
                    .font(.system(size: 40.sp * contentScale, weight: .bold))
            }

            // Second row: day + date
            HStack(spacing: 8.w * contentScale) {
                Text("\(dayName.uppercased()),")
                    .font(.system(size: 20.sp * contentScale, weight: .medium))

                Text(dateString.uppercased())
                    .font(.system(size: 20.sp * contentScale, weight: .medium))
            }
            .foregroundColor(Color(AppColors.white))
        }
        .padding(.trailing, 16.w * contentScale)
        .padding(.top, 8.h * contentScale)
        .padding(.bottom, 8.h * contentScale)
        .onAppear {
            updateTime()
            startSyncedTimer()
        }
    }

    // MARK: - Computed Properties

    var isDayTime: Bool {
        let hour = Calendar.current.component(.hour, from: currentDate)
        return hour >= 6 && hour < 18
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: currentDate)
    }

    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: currentDate)
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: currentDate)
    }

    // MARK: - Timer Helpers

    private func updateTime() {
        currentDate = Date()
    }

    private func startSyncedTimer() {
        guard !timerStarted else { return }
        timerStarted = true

        let now = Date()
        let calendar = Calendar.current
        let nextMinute = calendar.nextDate(after: now, matching: DateComponents(second: 0), matchingPolicy: .nextTime)!
        let delay = nextMinute.timeIntervalSince(now)

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            updateTime()
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                updateTime()
            }
        }
    }
}
