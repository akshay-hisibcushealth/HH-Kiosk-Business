import Foundation

enum ScanSessionStorage {
    static var measurementID: String? {
        let value = UserDefaults.standard.string(forKey: AppStorageKeys.measurementID)
        return value?.isEmpty == false ? value : nil
    }

    static func saveMeasurementID(_ measurementID: String?) {
        guard let measurementID, !measurementID.isEmpty else {
            clearMeasurementID()
            return
        }

        UserDefaults.standard.set(measurementID, forKey: AppStorageKeys.measurementID)
    }

    static func clearMeasurementID() {
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.measurementID)
    }
}
