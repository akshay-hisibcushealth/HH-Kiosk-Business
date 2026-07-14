import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"

    var id: String { rawValue }
    var locale: Locale { Locale(identifier: rawValue) }
}

enum AppLocalization {
    private static let selectedLanguageCodeKey = "app.selectedLanguageCode"

    static var currentLanguage: AppLanguage {
        let savedCode = UserDefaults.standard.string(forKey: selectedLanguageCodeKey)
        return AppLanguage(rawValue: savedCode ?? "") ?? .english
    }

    static func setLanguage(_ language: AppLanguage) {
        UserDefaults.standard.set(language.rawValue, forKey: selectedLanguageCodeKey)
    }

    static func string(_ key: String, defaultValue: String) -> String {
        localizedBundle.localizedString(forKey: key, value: defaultValue, table: nil)
    }

    static func format(_ key: String, defaultValue: String, _ arguments: CVarArg...) -> String {
        let localizedFormat = string(key, defaultValue: defaultValue)
        return String(format: localizedFormat, locale: currentLanguage.locale, arguments: arguments)
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
