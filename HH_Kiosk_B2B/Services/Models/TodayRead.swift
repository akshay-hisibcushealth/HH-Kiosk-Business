import Foundation

struct TodayRead: Codable, Identifiable {
    let id: Int
    let title: String
    let image: String
    let thumbnail: String
    let description: String
    let read_time: String
}

struct HRDeskItem: Codable, Identifiable {
    let id: Int
    let title: String
    let image: String
    let doc: String
}

struct APIResponse: Codable {
    let today_read: [TodayRead]
    let hrdesk: [HRDeskItem]
}
