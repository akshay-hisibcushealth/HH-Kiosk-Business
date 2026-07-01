//
//  ResultEntry+EmailResultPayload.swift
//  HHKiosk
//
//  Created by Applite Solutions on 25/08/25.
//



import Foundation

struct VitalsResultPayload: Codable {
    let email: String
    let demographic: Demographic
    let data: [String: ResultEntry]
    let brandCode: String
    let scanType: String

    enum CodingKeys: String, CodingKey {
        case email
        case demographic
        case data
        case brandCode = "brand_code"
        case scanType = "scan_type"
    }
}


struct Demographic: Codable {
    let age: Int
    let height: Int
    let weight: Int
    let gender: String
}
