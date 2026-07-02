//
//  ResultEntry+EmailResultPayload.swift
//  HHKiosk
//
//  Created by Applite Solutions on 25/08/25.
//



import Foundation

struct VitalsResultPayload: Codable {
    let brandCode: String
    let scanType: String
    let demographic: Demographic
    let results: [String: ResultEntry]

    enum CodingKeys: String, CodingKey {
        case brandCode = "brand_code"
        case scanType = "scan_type"
        case demographic
        case results
    }
}


struct Demographic: Codable {
    let email: String
    let age: Int
    let height: Int
    let weight: Int
    let gender: String
}
