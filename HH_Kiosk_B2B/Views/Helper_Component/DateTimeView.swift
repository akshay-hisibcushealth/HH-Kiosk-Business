import SwiftUI

struct DateTimeView: View {
    @State private var currentDate = Date()
    @State private var timerStarted = false

    var body: some View {
        VStack(alignment: .trailing) {
            // First row: icon + time
            HStack(spacing: 8) {
                Image(systemName: isDayTime ? "sun.max.fill" : "moon.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color(AppColors.secondary))

                Text(timeString)
                    .foregroundColor(Color(AppColors.secondary))
                    .font(.system(size: 40, weight: .bold))
            }

            // Second row: day + date
            HStack(spacing: 8) {
                Text("\(dayName.uppercased()),")
                    .font(.system(size: 20, weight: .medium))

                Text(dateString.uppercased())
                    .font(.system(size: 20, weight: .medium))
            }
            .foregroundColor(.white)
            .font(.subheadline)
        }
        .padding(.trailing, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
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
