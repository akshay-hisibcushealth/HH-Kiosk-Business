import Foundation

struct ScreenSaverItem: Codable, Identifiable {
    let id: Int
    let title: String
    let image: String
}

struct ScreenSaverResponse: Codable {
    let Data: [ScreenSaverItem]
}
