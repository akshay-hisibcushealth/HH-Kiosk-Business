//
//  Copyright (c) 2016-2023, Nuralogix Corp.
//  All Rights reserved
//  THIS SOFTWARE IS LICENSED BY AND IS THE CONFIDENTIAL AND
//  PROPRIETARY PROPERTY OF NURALOGIX CORP. IT IS
//  PROTECTED UNDER THE COPYRIGHT LAWS OF THE USA, CANADA
//  AND OTHER FOREIGN COUNTRIES. THIS SOFTWARE OR ANY
//  PART THEREOF, SHALL NOT, WITHOUT THE PRIOR WRITTEN CONSENT
//  OF NURALOGIX CORP, BE USED, COPIED, DISCLOSED,
//  DECOMPILED, DISASSEMBLED, MODIFIED OR OTHERWISE TRANSFERRED
//  EXCEPT IN ACCORDANCE WITH THE TERMS AND CONDITIONS OF A
//  NURALOGIX CORP SOFTWARE LICENSE AGREEMENT.
//

import Foundation

struct AnuraUser {
    
    enum Gender : String {
        case female
        case male
        case unknown
    }
    
    var partnerID : String?  // Optional string up to 48 characters long
    var height : Int         // cm
    var weight : Int         // kg
    var age    : Int         // years
    var gender : Gender      // male/female
    
    static var empty : Self {
        return AnuraUser(partnerID: nil,
                         height: -1,
                         weight: -1,
                         age: -1,
                         gender: .unknown)
    }
    
    var isValid : Bool {
        return hasValidAge && hasValidHeightAndWeight && hasKnownGender
    }
    
    var measurementProperties : [String: String] {
        guard isValid else {
            return [:]
        }
        
        return ["height": String(height),
                "weight": String(weight),
                "age": String(age),
                "gender": gender.rawValue]
    }
    
    var bmi : Double {
        let heightInMeters = Double(height) / 100
        let bmi = (Double(weight) / Double(heightInMeters * heightInMeters)).rounded()
        return bmi
    }
    
    var hasValidAge : Bool {
        return (13 ... 120).contains(age)
    }
    
    var hasValidHeightAndWeight : Bool {
         return (9 ... 66).contains(bmi) &&
                (120 ... 220).contains(height) &&
                (30 ... 300).contains(weight)
    }
    
    var hasKnownGender : Bool {
        return gender != .unknown
    }
}
