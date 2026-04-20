import Foundation

struct KioskScreenSaverResponse: Codable {
    let screensaverData: KioskBrandingScreenSaverData

    private enum CodingKeys: String, CodingKey {
        case screensaverData = "screensaver_data"
    }
}

struct KioskBrandingScreenSaverData: Codable {
    let welcomeText: String
    let subtitle: String
    let actionButtonText: String?
    let carouselImages: [KioskBrandingCarouselImage]

    private enum CodingKeys: String, CodingKey {
        case welcomeText = "welcome_text"
        case subtitle
        case actionButtonText = "action_button_text"
        case carouselImages = "carousel_images"
    }
}

struct KioskBrandingCarouselImage: Codable, Identifiable {
    let imageURL: String
    let title: String
    let order: Int

    // `order` is no longer unique because the QR item can share the same order
    // as a carousel image, so we use the remote image URL as the stable identity.
    var id: String { imageURL }

    private enum CodingKeys: String, CodingKey {
        case imageURL = "image_url"
        case title
        case order
    }
}
