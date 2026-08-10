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

    // Set to true for QA TestFlight builds and false for client builds.
    // This controls all Physical Attributes QA buttons and their actions.
    static let qaToolsEnabled = true

    // Screen capture is useful during development, but patient information must
    // be protected in TestFlight and production builds. Change either value when
    // a specific build needs different behavior.
#if DEBUG
static let sensitiveScreenCaptureEnabled = false // Test protection
#else
static let sensitiveScreenCaptureEnabled = false
#endif
    
    static let deepaffexAPIHostname = "api.deepaffex.ai"
    static let baseURL = "https://coremobileapidev.hibiscushealth.com"
    static let brandCode = "XSEWVGNV"
    static let scanType = "Kiosk"

}
