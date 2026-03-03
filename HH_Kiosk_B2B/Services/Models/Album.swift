//
//  Album.swift
//  HH_Kiosk_B2B
//
//  Created by Applite Solutions on 03/03/26.
//
import SwiftUI

struct Album: Identifiable, Codable {
    let id = UUID()
    let title: String
    let photos: [String]
    
    enum CodingKeys: String, CodingKey {
        case title
        case photos
    }
}
