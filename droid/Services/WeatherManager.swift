//
//  File.swift
//  droid
//
//  Created by ankudinov aleksandr on 26.06.2025.
//

import Foundation
import SwiftUI
import Combine

import Artemisia

class WeatherManager : ObservableObject {
    
    @Published var weatherData: Weather?
    
    var connectionManager = BLEConnectService.shared
    var client:Artemisia = Artemisia.connect(host:  Constants.baseEndpointURL,port: Int32(Constants.baseEndpointPort) ?? 1883 , version: .v5)
    
    private var bag = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.addObserver(forName: Constants.MQQTNotification, object: nil, queue: nil) { notification in
            self.updateSuscribtion()
        }
    }
    
    func updateSuscribtion() {
        
        client = Artemisia.connect(host:  Constants.baseEndpointURL,port: Int32(Constants.baseEndpointPort) ?? 1883 , version: .v5)
        
        connectionManager.connectedPeripheral?.weatherPublisher.sink(receiveCompletion: { completion in
            completionHandler: switch completion {
                default:
                break;
            }
        }, receiveValue: { weater in
            
                DispatchQueue.main.async {
                    self.weatherData = weater
                }
            
                if let temp = weater.temperature {
                    self.client["weather/temperature"].publish(message: String(temp))
                }
                
                if let humidity = weater.humidity {
                    self.client["weather/humidity"].publish(message: String(humidity))
                }
                
                if let pressure = weater.pressure {
                    self.client["weather/pressure"].publish(message: String(pressure))
                }
                
           
        }).store(in: &self.bag)
    }
    
}
