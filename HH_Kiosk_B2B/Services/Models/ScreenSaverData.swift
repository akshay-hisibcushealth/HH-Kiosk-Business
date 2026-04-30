struct ScreenSaverData: Codable {
    let welcomeText: String
    let subtitle: String
    let actionButtonText: String?
    let carouselImages: [ScreenSaverCarouselImage]

    private enum CodingKeys: String, CodingKey {
        case welcomeText = "welcome_text"
        case subtitle
        case actionButtonText = "action_button_text"
        case carouselImages = "carousel_images"
    }
}

struct ScreenSaverCarouselImage: Codable, Identifiable {
    let imageURL: String
    let title: String
    let order: Int

    var id: String { imageURL }

    private enum CodingKeys: String, CodingKey {
        case imageURL = "image_url"
        case title
        case order
    }
}
