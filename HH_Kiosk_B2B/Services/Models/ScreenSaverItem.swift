//
//  ScreenSaverItem.swift
//  HH_Kiosk_B2B
//
//  Created by Applite Solutions on 29/10/25.
//


import Foundation

struct ScreenSaverItem: Codable, Identifiable {
    let id: Int
    let title: String
    let image: String
}

struct ScreenSaverResponse: Codable {
    let Data: [ScreenSaverItem]
}
