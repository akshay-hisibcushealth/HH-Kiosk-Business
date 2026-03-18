//
//  LocalUserStorage.swift
//  HH_Kiosk_B2B
//
//  Created by Applite Solutions on 13/03/26.
//


import Foundation

struct LocalUserStorage {

    private static let emailKey = "user_email"
    private static let heightKey = "user_height"
    private static let weightKey = "user_weight"
    private static let ageKey = "user_age"
    private static let genderKey = "user_gender"

    static func saveUser(
        email: String,
        height: Int,
        weight: Int,
        age: Int,
        gender: String
    ) {

        let defaults = UserDefaults.standard

        defaults.set(email, forKey: emailKey)
        defaults.set(height, forKey: heightKey)
        defaults.set(weight, forKey: weightKey)
        defaults.set(age, forKey: ageKey)
        defaults.set(gender, forKey: genderKey)

        defaults.synchronize()
    }

    static func clearUser() {
        let defaults = UserDefaults.standard

        defaults.removeObject(forKey: emailKey)
        defaults.removeObject(forKey: heightKey)
        defaults.removeObject(forKey: weightKey)
        defaults.removeObject(forKey: ageKey)
        defaults.removeObject(forKey: genderKey)
    }
}
