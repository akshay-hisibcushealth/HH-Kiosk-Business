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

enum AppConfig {

    // Enables QA buttons/actions and the development API.
    // Set to false for production TestFlight/client builds.
    static let qaToolsEnabled = true

    // Set to true to allow screen capture, or false to protect sensitive screens.
    static let screenCaptureEnabled = true
    
    static let deepaffexAPIHostname = "api.deepaffex.ai"
    static let baseURL = qaToolsEnabled
        ? "https://coremobileapidev.hibiscushealth.com"
        : "https://coremobileapiprod.hibiscushealth.com"
    static let brandCode = "XSEWVGNV"
    static let scanType = "Kiosk"

}
