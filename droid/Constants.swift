//
//  Constants.swift
//  droid
//
//  Created by ankudinov aleksandr on 25.06.2025.
//

import Foundation
import SwiftUI

// Констатнти для керування додатком
struct Constants {
    @AppStorage("baseEndpointURL")  static var baseEndpointURL = "13.48.148.89"
    @AppStorage("baseEndpointPort") static var baseEndpointPort = "1883"
    
    static let MQQTNotification = Notification.Name("MQQTHOSTUPDATED")
    
    struct BluetoothService {
        static let serviceUUID = "EF680200-9B35-4933-9B10-52FFA9740042"
        
        struct BluetoothServiceChannels {
            static let temperatureChannel =     "506A55C4-B5E7-46FA-8326-8ACAEB1189EB"
            static let humidityChannel =        "51838AFF-2D9A-B32A-B32A-8187E41664BA"
            static let pressureChannel =        "753E3050-DF06-4B53-B090-5E1D810C4383"
        }
    }
        

}

