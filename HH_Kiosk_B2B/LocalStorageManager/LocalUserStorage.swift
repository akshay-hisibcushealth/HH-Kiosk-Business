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

        let defaults = UserDefaults.standard

        defaults.set(email, forKey: emailKey)
        defaults.set(height, forKey: heightKey)
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
        defaults.removeObject(forKey: weightKey)
        defaults.removeObject(forKey: weightInPoundsKey)
        defaults.removeObject(forKey: ageKey)
        defaults.removeObject(forKey: genderKey)
        defaults.removeObject(forKey: measurementResultsKey)
    }

    static func loadUser() -> StoredUser? {
        let defaults = UserDefaults.standard
        guard let email = defaults.string(forKey: emailKey),
              let gender = defaults.string(forKey: genderKey) else {
            return nil
        }

        let weight = defaults.integer(forKey: weightKey)
        let savedWeightInPounds = defaults.integer(forKey: weightInPoundsKey)

        return StoredUser(
            email: email,
            height: defaults.integer(forKey: heightKey),
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
