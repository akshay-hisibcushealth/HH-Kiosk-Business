//
//  ResultEntry+EmailResultPayload.swift
//  HHKiosk
//
//  Created by Applite Solutions on 25/08/25.
//



import Foundation

struct ResultEntry: Codable {
    let value: Double
    let notes: [String]
}

struct EmailResultPayload: Codable {
    let email: String
    let measurementID: String
    let pin: String

    enum CodingKeys: String, CodingKey {
        case email
        case measurementID = "measurement_id"
        case pin
    }
}
