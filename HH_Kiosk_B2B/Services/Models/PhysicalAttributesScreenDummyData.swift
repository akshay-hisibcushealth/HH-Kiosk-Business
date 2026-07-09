import Foundation

enum PhysicalAttributesScreenDummyData {
    static var customization: PhysicalAttributesScreenCustomization {
        loadCustomization() ?? fallbackCustomization
    }

    private static let fallbackCustomization = PhysicalAttributesScreenCustomization(
        titleText: "Tell us about yourself",
        subtitleText: "We use these details to ensure your scan results are as accurate as possible.",
        privacyMessageText: "Your privacy is protected. Your information will NOT be stored during this process and will only be used for calculations.",
        watchDemoButtonText: "Watch Demo",
        watchDemoButtonBackgroundColorHex: "#E8E8E8",
        watchDemoButtonTextColorHex: "#241F1F",
        watchDemoButtonIconColorHex: "#241F1F",
        proceedToScanButtonText: "Proceed to Scan",
        proceedToScanButtonBackgroundColorHex: "#B8EB5E"
    )

    private static func loadCustomization() -> PhysicalAttributesScreenCustomization? {
        guard let url = Bundle.main.url(
            forResource: "physical_attributes_screen_dummy",
            withExtension: "json"
        ) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(PhysicalAttributesScreenCustomization.self, from: data)
        } catch {
            print("[PhysicalAttributesScreenDummyData] Failed to load dummy data: \(error)")
            return nil
        }
    }
}
