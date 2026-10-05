import SwiftUI

private struct AppLanguageEnvironment: ViewModifier {
    @AppStorage(AppLocalization.selectedLanguageCodeKey)
    private var languageCode = AppConfig.defaultLanguage.rawValue

    func body(content: Content) -> some View {
        // Rebuild rendered strings when the language is selected before a session.
        content
            .id(languageCode)
            .environment(\.locale, (AppLanguage(rawValue: languageCode) ?? AppConfig.defaultLanguage).locale)
    }
}

extension View {
    /// Apply to each SwiftUI root, including separately presented hosting controllers.
    func appLanguageEnvironment() -> some View {
        modifier(AppLanguageEnvironment())
    }
}
