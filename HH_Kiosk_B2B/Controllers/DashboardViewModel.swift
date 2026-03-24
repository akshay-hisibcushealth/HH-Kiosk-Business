import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var todayRead: TodayRead?
    @Published var hrDeskItems: [HRDeskItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let contentService: KioskContentServiceProtocol

    init(contentService: KioskContentServiceProtocol = KioskContentService()) {
        self.contentService = contentService
        fetchData()
    }

    func fetchData() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await contentService.fetchDashboardData()
                self.isLoading = false
                self.todayRead = response.today_read.first
                self.hrDeskItems = response.hrdesk
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
