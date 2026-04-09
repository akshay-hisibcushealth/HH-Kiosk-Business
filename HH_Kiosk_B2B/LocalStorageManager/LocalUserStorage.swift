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
    let age: Int
    let gender: String
}

struct LocalUserStorage {

    private static let clientIDKey = "client_id"
    private static let emailKey = "user_email"
    private static let heightKey = "user_height"
    private static let weightKey = "user_weight"
    private static let ageKey = "user_age"
    private static let genderKey = "user_gender"

    static func saveClientID(_ clientID: String) {
        let trimmedClientID = clientID.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(trimmedClientID, forKey: clientIDKey)
    }

    static func loadClientID() -> String? {
        guard let clientID = UserDefaults.standard.string(forKey: clientIDKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !clientID.isEmpty else {
            return nil
        }

        return clientID
    }

    static func clearClientID() {
        UserDefaults.standard.removeObject(forKey: clientIDKey)
    }

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

    static func loadUser() -> StoredUser? {
        let defaults = UserDefaults.standard
        guard let email = defaults.string(forKey: emailKey),
              let gender = defaults.string(forKey: genderKey) else {
            return nil
        }

        return StoredUser(
            email: email,
            height: defaults.integer(forKey: heightKey),
            weight: defaults.integer(forKey: weightKey),
            age: defaults.integer(forKey: ageKey),
            gender: gender
        )
    }
}
