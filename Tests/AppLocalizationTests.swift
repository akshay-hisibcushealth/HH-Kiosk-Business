import Foundation

// The runner bundles production resources and isolates preferences from the kiosk app.
@main
struct AppLocalizationTests {
    static func main() throws {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: AppLocalization.selectedLanguageCodeKey)
        defer {
            defaults.removeObject(forKey: AppLocalization.selectedLanguageCodeKey)
            defaults.removeObject(forKey: "AppleLanguages")
        }

        precondition(AppLocalization.currentLanguage == .english)
        defaults.set("unsupported", forKey: AppLocalization.selectedLanguageCodeKey)
        precondition(AppLocalization.currentLanguage == .english)
        AppLocalization.activateBundleLanguageOverride()
        // Repeated activation must be safe (for example, in previews).
        AppLocalization.activateBundleLanguageOverride()

        let english = try strings(for: .english)
        let spanish = try strings(for: .spanish)
        precondition(Set(english.keys).subtracting(["test.englishOnly"]) == Set(spanish.keys))
        let expectedMetrics: Set<String> = ["BP_CVD", "BP_SYSTOLIC", "BP_DIASTOLIC", "HR_BPM", "HBA1C_RISK_PROB", "HDLTC_RISK_PROB", "TG_RISK_PROB"]
        var englishInterpretations: [String: [String: String]] = [:]

        for language in [AppLanguage.english, .spanish, .english] {
            AppLocalization.setLanguage(language)
            precondition(AppLocalization.currentLanguage == language)
            precondition(defaults.string(forKey: AppLocalization.selectedLanguageCodeKey) == language.rawValue)
            precondition(defaults.stringArray(forKey: "AppleLanguages") == [language.rawValue])
            precondition(language.backendDisplayName == (language == .english ? "English" : "Spanish"))
            let resources = language == .english ? english : spanish
            for (key, value) in resources {
                precondition(AppLocalization.string(key, defaultValue: "MISSING") == value, "Lookup failed: \(language) \(key)")
                precondition(Bundle.main.localizedString(forKey: key, value: "MISSING", table: nil) == value, "SDK lookup failed: \(key)")
            }
            precondition(AppLocalization.string("test.englishOnly", defaultValue: "fallback") == "English fallback")
            precondition(AppLocalization.string("test.absent", defaultValue: "Explicit fallback") == "Explicit fallback")
            precondition(Bundle.main.localizedString(forKey: "test.absent", value: nil, table: nil) == "test.absent")
            precondition(PhysicalAttributesScreenStrings.Form.genderOptions == ["Male", "Female"])
            precondition(PhysicalAttributesScreenStrings.Form.genderTitle(for: "Male") == (language == .english ? "Male" : "Masculino"))
            precondition(PhysicalAttributesScreenStrings.Form.genderTitle(for: "Female") == (language == .english ? "Female" : "Femenino"))
            precondition(Set(ResultScreenStrings.Metrics.interpretations.keys) == expectedMetrics)
            for (metric, messages) in ResultScreenStrings.Metrics.interpretations {
                precondition(!messages.isEmpty && messages.values.allSatisfy { !$0.isEmpty })
                if language == .spanish {
                    precondition(Set(messages.keys) == Set(englishInterpretations[metric]!.keys))
                    for (bucket, message) in messages {
                        precondition(message != englishInterpretations[metric]![bucket], "Untranslated interpretation: \(metric) \(bucket)")
                    }
                }
            }
            if language == .english {
                englishInterpretations = ResultScreenStrings.Metrics.interpretations
                precondition(ResultScreenStrings.PostSession.allDoneTitle == "Thank you for visiting our kiosk!")
                precondition(ResultScreenStrings.Metrics.displayTitle(for: "BP_CVD") == "Adverse Cardiovascular Event Risk")
                precondition(PhysicalAttributesScreenStrings.Form.emailLabel == "Email (We send your results here)")
            } else {
                precondition(ResultScreenStrings.PostSession.allDoneTitle == "¡Gracias por visitar nuestro kiosco!")
                precondition(ResultScreenStrings.Metrics.displayTitle(for: "BP_CVD") == "Riesgo de evento cardiovascular adverso")
            }
            let formatter = AppLocalization.dateFormatter(format: "EEEE")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            let monday = Date(timeIntervalSince1970: 1_791_158_400) // 2026-10-05 UTC
            precondition(formatter.string(from: monday) == (language == .english ? "Monday" : "lunes"))
            let progress = AppLocalization.format("app.current.Step_d_of_d", defaultValue: "Step %d of %d: %@", 2, 3, "Report")
            precondition(progress == (language == .english ? "Step 2 of 3: Report" : "Paso 2 de 3: Report"))
        }
        print("PASS: English/Spanish resources, live lookups, persisted selection, SDK bundle override, fallbacks, stable gender/metric values, formatting, and dates.")
    }

    static func strings(for language: AppLanguage) throws -> [String: String] {
        let path = Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language.rawValue)!
        return try PropertyListSerialization.propertyList(from: Data(contentsOf: URL(fileURLWithPath: path)), format: nil) as! [String: String]
    }
}
