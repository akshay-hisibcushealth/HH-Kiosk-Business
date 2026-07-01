//
//  LocalUserStorage.swift
//  HH_Kiosk_B2B
//
//  Created by Applite Solutions on 13/03/26.
//


import Foundation

struct StoredUser {
    let email: String
    let height: Int
    let heightForBackend: Int
    let weight: Int
    let weightInPounds: Int
    let age: Int
    let gender: String
}

struct LocalUserStorage {

    private static let emailKey = "user_email"
    private static let heightKey = "user_height"
    private static let heightForBackendKey = "user_height_backend"
    private static let weightKey = "user_weight"
    private static let weightInPoundsKey = "user_weight_lbs"
    private static let ageKey = "user_age"
    private static let genderKey = "user_gender"

    static func saveUser(
        email: String,
        height: Int,
        heightForBackend: Int,
        weight: Int,
        weightInPounds: Int,
        age: Int,
        gender: String
    ) {

        let defaults = UserDefaults.standard

        defaults.set(email, forKey: emailKey)
        defaults.set(height, forKey: heightKey)
        defaults.set(heightForBackend, forKey: heightForBackendKey)
        defaults.set(weight, forKey: weightKey)
        defaults.set(weightInPounds, forKey: weightInPoundsKey)
        defaults.set(age, forKey: ageKey)
        defaults.set(gender, forKey: genderKey)

        defaults.synchronize()
    }

    static func clearUser() {
        let defaults = UserDefaults.standard

        defaults.removeObject(forKey: emailKey)
        defaults.removeObject(forKey: heightKey)
        defaults.removeObject(forKey: heightForBackendKey)
        defaults.removeObject(forKey: weightKey)
        defaults.removeObject(forKey: weightInPoundsKey)
        defaults.removeObject(forKey: ageKey)
        defaults.removeObject(forKey: genderKey)
    }

    static func loadUser() -> StoredUser? {
        let defaults = UserDefaults.standard
        guard let email = defaults.string(forKey: emailKey),
              let gender = defaults.string(forKey: genderKey) else {
            return nil
        }

        let weight = defaults.integer(forKey: weightKey)
        let savedWeightInPounds = defaults.integer(forKey: weightInPoundsKey)
        let height = defaults.integer(forKey: heightKey)
        let savedHeightForBackend = defaults.integer(forKey: heightForBackendKey)

        return StoredUser(
            email: email,
            height: height,
            heightForBackend: savedHeightForBackend > 0 ? savedHeightForBackend : height,
            weight: weight,
            weightInPounds: savedWeightInPounds > 0 ? savedWeightInPounds : Int(Double(weight) * 2.20462),
            age: defaults.integer(forKey: ageKey),
            gender: gender
        )
    }

    static func loadEmail() -> String? {
        UserDefaults.standard.string(forKey: emailKey)
    }
}
