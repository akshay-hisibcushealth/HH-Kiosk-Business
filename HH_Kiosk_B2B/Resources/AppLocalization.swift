import Foundation
import ObjectiveC.runtime

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"

    var id: String { rawValue }
    var locale: Locale { Locale(identifier: rawValue) }
    var backendDisplayName: String {
        switch self {
        case .english:
            return "English"
        case .spanish:
            return "Spanish"
        }
    }
}

enum AppLocalization {
    private static let selectedLanguageCodeKey = "app.selectedLanguageCode"
    private static let appleLanguagesKey = "AppleLanguages"

    static var currentLanguage: AppLanguage {
        let savedCode = UserDefaults.standard.string(forKey: selectedLanguageCodeKey)
        return AppLanguage(rawValue: savedCode ?? "") ?? .english
    }

    static func activateBundleLanguageOverride() {
        object_setClass(Bundle.main, SelectedLanguageBundle.self)
        applySystemLanguagePreference(currentLanguage)
    }

    static func setLanguage(_ language: AppLanguage) {
        UserDefaults.standard.set(language.rawValue, forKey: selectedLanguageCodeKey)
        applySystemLanguagePreference(language)
    }

    static func string(_ key: String, defaultValue: String) -> String {
        localizedBundle.localizedString(forKey: key, value: defaultValue, table: nil)
    }

    static func format(_ key: String, defaultValue: String, _ arguments: CVarArg...) -> String {
        let localizedFormat = string(key, defaultValue: defaultValue)
        return String(format: localizedFormat, locale: currentLanguage.locale, arguments: arguments)
    }

    static func dateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = currentLanguage.locale
        formatter.dateFormat = format
        return formatter
    }

    static func bundleString(_ key: String, value: String?, table tableName: String?) -> String {
        localizedBundle.localizedString(forKey: key, value: value, table: tableName)
    }

    private static func applySystemLanguagePreference(_ language: AppLanguage) {
        UserDefaults.standard.set([language.rawValue], forKey: appleLanguagesKey)
        UserDefaults.standard.synchronize()
    }

    private static var localizedBundle: Bundle {
        guard
            let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return .main
        }

        return bundle
    }
}

private final class SelectedLanguageBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        AppLocalization.bundleString(key, value: value, table: tableName)
    }
}
