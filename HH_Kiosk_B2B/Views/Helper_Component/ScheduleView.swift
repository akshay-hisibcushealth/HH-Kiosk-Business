import SwiftUI

struct Schedule: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let startTime: Date
    let endTime: Date
    let color: Color
}

class ScheduleViewModel: ObservableObject {
    @Published var schedulesByDay: [Date: [Schedule]] = [:]
    
    init() {
        generateSchedule()
    }
    
    private func generateSchedule() {
        let calendar = Calendar.current
        let today = Date()
        
        // Example event pool (besides Daily Stand-Up)
        let eventPool: [(String, String, Color)] = [
            ("Quarterly Town Hall Meeting", "To discuss about the upcoming project & organization of units", Color(AppColors.scheduleEventPeach)),
            ("Q3 Wellness Challenge begins", "To discuss about the upcoming project & organization of units", Color(AppColors.scheduleEventBlue)),
            ("Diversity, Equity & Inclusion (DEI) Awareness Days", "Panels, training, and celebration of heritage months or cultural milestones.", Color(AppColors.scheduleEventPeach)),
            ("Wellness Week / Health Fair", "Activities focused on physical and mental well-being.", Color(AppColors.scheduleEventBlue)),
            ("Hackathons / Innovation Days", "Creative sprints where teams develop solutions, tools, or prototypes.", Color(AppColors.scheduleEventPeach)),
            ("Team-Building Retreat", "A full-day or overnight program to boost collaboration and morale.", Color(AppColors.scheduleEventBlue)),
            ("Company Anniversary", "Celebration of the organization's founding and journey.", Color(AppColors.scheduleEventPeach)),
            ("Open Enrollment / Benefits Fair", "Informational sessions on employee benefits, insurance, and perks.", Color(AppColors.scheduleEventBlue)),
            ("Community Service / Volunteer Day", "Team-led initiatives supporting local organizations.", Color(AppColors.scheduleEventPeach)),
            ("Mid-Year Review", "Alignment on key metrics, shifting priorities, and future plans.", Color(AppColors.scheduleEventBlue)),
            ("New Employee Welcome Sessions", "Monthly or quarterly onboarding experiences with leadership meet-and-greets.", Color(AppColors.scheduleEventPeach))
        ]
        
        for offset in 0..<5 {
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            
            let weekday = calendar.component(.weekday, from: date)
            // 1 = Sunday, 7 = Saturday
            if weekday == 1 || weekday == 7 {
                schedulesByDay[date] = [] // weekend → no schedule
                continue
            }
            
            var events: [Schedule] = []
            
            // Add Daily Stand-Up at fixed time
            let dailyStart = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: date)!
            let dailyEnd = calendar.date(bySettingHour: 11, minute: 30, second: 0, of: date)!
            
            events.append(
                Schedule(
                    title: "Daily Stand-Up",
                    description: "A stand-up meeting is a meeting in which attendees typically participate while standing.",
                    startTime: dailyStart,
                    endTime: dailyEnd,
                    color: Color(AppColors.scheduleStandupBackground)
                )
            )
            
            // Pick 2 random other events from pool
            let randomEvents = eventPool.shuffled().prefix(2)
            for (title, desc, color) in randomEvents {
                let randomHour = [8, 9].randomElement()! // e.g., 8:30 or 9:30
                let start = calendar.date(bySettingHour: randomHour, minute: 30, second: 0, of: date)!
                let end = calendar.date(bySettingHour: randomHour+1, minute: 0, second: 0, of: date)!
                
                events.append(
                    Schedule(title: title, description: desc, startTime: start, endTime: end, color: color)
                )
            }
            
            // Sort by time
            schedulesByDay[date] = events.sorted { $0.startTime < $1.startTime }
        }
    }
}


// MARK: - Views
struct ScheduleView: View {
    @StateObject private var viewModel = ScheduleViewModel()
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // Title
            SectionHeader(title: "Today's Schedule",isLeading: true).padding(.top,12.h)
            // Horizontal Days (5 days from today)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.flexible())], spacing: 0) {
                    ForEach(0..<5) { offset in
                        let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
                        
                        VStack {
                            Text(date, format: .dateTime.day())
                                .font(.system(size: 24.sp, weight: .medium))
                                .foregroundColor(
                                    Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color(AppColors.white) : Color(AppColors.scheduleDayText)
                                )
                            
                            Text(date, format: .dateTime.weekday(.abbreviated))
                                .font(.system(size: 28.sp))
                                .foregroundColor(
                                    Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color(AppColors.white) : Color(AppColors.scheduleDayText)
                                )
                        }
                        .frame(width: 75.w, height: 130.h)
                        .background(
                            Calendar.current.isDate(date, inSameDayAs: selectedDate)
                            ? Color(AppColors.primaryActionOrange)
                            : Color(AppColors.clear)
                        )
                        .clipShape(Capsule())
                        .onTapGesture {
                            selectedDate = date
                        }
                        .padding(.horizontal,10.w)
                    }
                }
            }
            
            // Daily schedule
            ScrollView {
                VStack(alignment: .leading) {
                    let todaysSchedules = viewModel.schedulesByDay.keys
                        .first(where: { Calendar.current.isDate($0, inSameDayAs: selectedDate) })
                        .flatMap { viewModel.schedulesByDay[$0] } ?? []
                    
                    if todaysSchedules.isEmpty {
                        VStack{
                            Image("no_schedule")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 56.w, height: 56.h)
                            Text("No Schedule")
                                .font(.system(size: 20.sp,weight: .medium))
                                .foregroundColor(Color(AppColors.scheduleEmptyText))
                                .padding(.top,16.h)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200.h)

                    } else {
                        ForEach(todaysSchedules) { schedule in
                            VStack(alignment: .leading) {
                                Text(schedule.title)
                                    .font(.system(size: 22.sp, weight: .semibold))
                                    .lineLimit(1)
                                    .foregroundColor(Color(AppColors.scheduleTitleText))
                                Text(schedule.startTime, style: .time)
                                    .font(.system(size: 18.sp, weight: .bold))
                                    .foregroundColor(Color(AppColors.scheduleTimeText))

                            }
                            .padding(.all,24.w)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(AppColors.scheduleCardBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 20.r))
                            
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    
        .background(Color(AppColors.overlayMint))
        .clipShape(RoundedRectangle(cornerRadius: 24.r))
    }
}
