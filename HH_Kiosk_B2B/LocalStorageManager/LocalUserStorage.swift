//
//  LocalUserStorage.swift
//  HH_Kiosk_B2B
//
//  Created by Applite Solutions on 13/03/26.
//


import Foundation

struct StoredUser: Codable {
    let email: String
    let height: Int
    let weight: Int
    let weightInPounds: Int
    let age: Int
    let gender: String
}

struct LocalUserStorage {

    private static let clientIDKey = "client_id"
    private static let emailKey = "user_email"
    private static let heightKey = "user_height"
    private static let weightKey = "user_weight"
    private static let weightInPoundsKey = "user_weight_lbs"
    private static let ageKey = "user_age"
    private static let genderKey = "user_gender"
    private static let measurementResultsKey = "measurement_results"
    private static let secureUserKey = "patient_demographics"

    static func clearClientID() {
        UserDefaults.standard.removeObject(forKey: clientIDKey)
    }

    static func saveUser(
        email: String,
        height: Int,
        weight: Int,
        weightInPounds: Int,
        age: Int,
        gender: String
    ) {

        let user = StoredUser(
            email: email,
            height: height,
            weight: weight,
            weightInPounds: weightInPounds,
            age: age,
            gender: gender
        )
        if let data = try? JSONEncoder().encode(user),
           SecureStorage.set(data, forKey: secureUserKey) {
            removeLegacyUserDefaults()
        }
    }

    static func clearUser() {
        SecureStorage.removeValue(forKey: secureUserKey)
        removeLegacyUserDefaults()
        UserDefaults.standard.removeObject(forKey: measurementResultsKey)
    }

    static func loadUser() -> StoredUser? {
        if let data = SecureStorage.data(forKey: secureUserKey),
           let user = try? JSONDecoder().decode(StoredUser.self, from: data) {
            removeLegacyUserDefaults()
            return user
        }

        return migrateLegacyUserIfNeeded()
    }

    static func loadEmail() -> String? {
        loadUser()?.email
    }

    private static func migrateLegacyUserIfNeeded() -> StoredUser? {
        let defaults = UserDefaults.standard
        guard let email = defaults.string(forKey: emailKey),
              let gender = defaults.string(forKey: genderKey) else {
            return nil
        }

        let weight = defaults.integer(forKey: weightKey)
        let savedWeightInPounds = defaults.integer(forKey: weightInPoundsKey)

        let user = StoredUser(
            email: email,
            height: defaults.integer(forKey: heightKey),
            weight: weight,
            weightInPounds: savedWeightInPounds > 0 ? savedWeightInPounds : Int(Double(weight) * 2.20462),
            age: defaults.integer(forKey: ageKey),
            gender: gender
        )
        if let data = try? JSONEncoder().encode(user),
           SecureStorage.set(data, forKey: secureUserKey) {
            removeLegacyUserDefaults()
        }
        return user
    }

    private static func removeLegacyUserDefaults() {
        let defaults = UserDefaults.standard
        [emailKey, heightKey, weightKey, weightInPoundsKey, ageKey, genderKey].forEach {
            defaults.removeObject(forKey: $0)
        }
    }
}
