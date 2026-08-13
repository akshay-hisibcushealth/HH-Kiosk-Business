import Foundation

enum ScanSessionStorage {
    private static let secureMeasurementIDKey = "session_measurement_id"

    static var measurementID: String? {
        let value = SecureStorage.string(
            forKey: secureMeasurementIDKey,
            migratingFromUserDefaultsKey: AppStorageKeys.measurementID
        )
        return value?.isEmpty == false ? value : nil
    }

    static func saveMeasurementID(_ measurementID: String?) {
        guard let measurementID, !measurementID.isEmpty else {
            clearMeasurementID()
            return
        }

        if SecureStorage.setString(measurementID, forKey: secureMeasurementIDKey) {
            UserDefaults.standard.removeObject(forKey: AppStorageKeys.measurementID)
        }
    }

    static func clearMeasurementID() {
        SecureStorage.removeValue(forKey: secureMeasurementIDKey)
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.measurementID)
    }
}
