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
}


struct Demographic: Codable {
    let age: Int
    let height: Int
    let weight: Int
    let gender: String
}
