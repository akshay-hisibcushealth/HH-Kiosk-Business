import Foundation
import ObjectiveC.runtime

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case chinese = "zh-Hans"
    case spanish = "es"
    case vietnamese = "vi"
    case filipino = "fil"
    case hindi = "hi"
    case arabic = "ar"

    var id: String { rawValue }
    var locale: Locale { Locale(identifier: rawValue) }
    var isRightToLeft: Bool { self == .arabic }
    var backendDisplayName: String {
        switch self {
        case .english: return "English"
        case .chinese: return "Chinese"
        case .spanish: return "Spanish"
        case .vietnamese: return "Vietnamese"
        case .filipino: return "Filipino"
        case .hindi: return "Hindi"
        case .arabic: return "Arabic"
        }
    }
}

enum AppLocalization {
    static let selectedLanguageCodeKey = "app.selectedLanguageCode"

    static var currentLanguage: AppLanguage {
        let savedCode = UserDefaults.standard.string(forKey: selectedLanguageCodeKey)
        return AppLanguage(rawValue: savedCode ?? "") ?? AppConfig.defaultLanguage
    }

    // Also localizes SDK strings resolved through Bundle.main.
    static func activateBundleLanguageOverride() {
        object_setClass(Bundle.main, SelectedLanguageBundle.self)
        applySystemLanguagePreference(currentLanguage)
    }

    /// Call before starting a scan. The preference persists across app launches.
    static func setLanguage(_ language: AppLanguage) {
        UserDefaults.standard.set(language.rawValue, forKey: selectedLanguageCodeKey)
        applySystemLanguagePreference(language)
    }

    static func string(_ key: String, defaultValue: String) -> String {
        bundleString(key, value: defaultValue, table: nil)
    }

    static func format(_ key: String, defaultValue: String, _ arguments: CVarArg...) -> String {
        String(format: string(key, defaultValue: defaultValue), locale: currentLanguage.locale, arguments: arguments)
    }

    static func dateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = currentLanguage.locale
        formatter.dateFormat = format
        return formatter
    }

    static func bundleString(_ key: String, value: String?, table: String?) -> String {
        // Never fall back to Bundle.main here: its override would recurse.
        let fallback = bundle(for: .english)?.localizedString(forKey: key, value: value, table: table) ?? value ?? key
        return bundle(for: currentLanguage)?.localizedString(forKey: key, value: fallback, table: table) ?? fallback
    }

    private static func bundle(for language: AppLanguage) -> Bundle? {
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj") else { return nil }
        return Bundle(path: path)
    }

    private static func applySystemLanguagePreference(_ language: AppLanguage) {
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
    }
}

private final class SelectedLanguageBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        AppLocalization.bundleString(key, value: value, table: tableName)
    }
}
