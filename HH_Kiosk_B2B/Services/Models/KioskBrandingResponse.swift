import Foundation
import SwiftUI

struct KioskBrandingResponse: Decodable {
    let brandingInfo: KioskBrandingInfo
    let physicalAttributesScreen: PhysicalAttributesScreenCustomization?

    private enum CodingKeys: String, CodingKey {
        case brandingInfo = "branding_info"
        case physicalAttributesScreen = "physical_attributes_screen"
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

struct PhysicalAttributesScreenCustomization: Decodable {
    let titleText: String
    let subtitleText: String
    let privacyMessageText: String
    let watchDemoButtonText: String
    let watchDemoButtonBackgroundColorHex: String
    let watchDemoButtonTextColorHex: String
    let watchDemoButtonIconColorHex: String
    let proceedToScanButtonText: String
    let proceedToScanButtonBackgroundColorHex: String

    private enum CodingKeys: String, CodingKey {
        case titleText = "title_text"
        case subtitleText = "subtitle_text"
        case privacyMessageText = "privacy_message_text"
        case watchDemoButtonText = "watch_demo_button_text"
        case watchDemoButtonBackgroundColorHex = "watch_demo_button_background_color_hex"
        case watchDemoButtonTextColorHex = "watch_demo_button_text_color_hex"
        case watchDemoButtonIconColorHex = "watch_demo_button_icon_color_hex"
        case proceedToScanButtonText = "proceed_to_scan_button_text"
        case proceedToScanButtonBackgroundColorHex = "proceed_to_scan_button_background_color_hex"
    }
}

extension PhysicalAttributesScreenCustomization {
    var watchDemoBackgroundColor: Color {
        color(from: watchDemoButtonBackgroundColorHex, fallback: Color(AppColors.gray).opacity(0.18))
    }

    var watchDemoTextColor: Color {
        color(from: watchDemoButtonTextColorHex, fallback: Color(AppColors.sectionHeaderText))
    }

    var watchDemoIconColor: Color {
        color(from: watchDemoButtonIconColorHex, fallback: Color(AppColors.sectionHeaderText))
    }

    var proceedToScanBackgroundColor: Color {
        color(from: proceedToScanButtonBackgroundColorHex, fallback: Color(AppColors.ctaGreen))
    }

    private func color(from hex: String, fallback: Color) -> Color {
        let cleanedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard cleanedHex.count == 6 || cleanedHex.count == 8 else {
            return fallback
        }

        return Color(hex: hex)
    }
}
