import Foundation

struct KioskBrandingResponse: Decodable {
    let brandingInfo: KioskBrandingInfo

    private enum CodingKeys: String, CodingKey {
        case brandingInfo = "branding_info"
    }
}

struct KioskBrandingInfo: Decodable {
    let companyName: String
    let primaryColorHex: String
    let accentColorHex: String
    let onAccentColorHex: String?
    let highlightedDayBackgroundHex: String?
    let scheduleBackgroundHex: String?
    let resultScreenDescription: String?
    let logo: String

    private enum CodingKeys: String, CodingKey {
        case companyName = "company_name"
        case primaryColorHex = "primary_color_hex"
        case accentColorHex = "accent_color_hex"
        case onAccentColorHex = "on_accent_color_hex"
        case highlightedDayBackgroundHex = "highlighted_day_background_hex"
        case scheduleBackgroundHex = "schedule_background_hex"
        case resultScreenDescription = "result_screen_description"
        case logo
    }
}
