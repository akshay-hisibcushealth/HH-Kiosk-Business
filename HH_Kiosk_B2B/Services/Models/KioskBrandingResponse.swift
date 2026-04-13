import Foundation

struct KioskBrandingResponse: Decodable {
    let brandingInfo: KioskBrandingInfo
    let screensaverData: KioskBrandingScreenSaverData

    private enum CodingKeys: String, CodingKey {
        case brandingInfo = "branding_info"
        case screensaverData = "screensaver_data"
    }
}

struct KioskBrandingInfo: Decodable {
    let companyName: String
    let primaryColorHex: String
    let accentColorHex: String
    let logo: String

    private enum CodingKeys: String, CodingKey {
        case companyName = "company_name"
        case primaryColorHex = "primary_color_hex"
        case accentColorHex = "accent_color_hex"
        case logo
    }
}

struct KioskBrandingScreenSaverData: Decodable {
    let welcomeText: String
    let subtitle: String
    let carouselImages: [KioskBrandingCarouselImage]

    private enum CodingKeys: String, CodingKey {
        case welcomeText = "welcome_text"
        case subtitle
        case carouselImages = "carousel_images"
    }
}

struct KioskBrandingCarouselImage: Decodable, Identifiable {
    let imageURL: String
    let order: Int

    var id: Int { order }

    private enum CodingKeys: String, CodingKey {
        case imageURL = "image_url"
        case order
    }
}
