import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var todayRead: TodayRead?
    @Published var hrDeskItems: [HRDeskItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        fetchData()
    }

    func fetchData() {
        isLoading = true
        errorMessage = nil

        NetworkManager.shared.fetchDashboardData { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                self.isLoading = false

                switch result {
                case .success(let response):
                    self.todayRead = response.today_read.first
                    self.hrDeskItems = response.hrdesk
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
