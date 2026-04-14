import Foundation

struct KioskScreenSaverResponse: Decodable {
    let screensaverData: KioskBrandingScreenSaverData

    private enum CodingKeys: String, CodingKey {
        case screensaverData = "screensaver_data"
    }
}
