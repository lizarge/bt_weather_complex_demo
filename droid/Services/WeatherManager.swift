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

//WeatherManager який імлементує бізнес логіку для отримання даних погоди з блютуз менеджера і публікація до MQTT брокера
//Володіє сервісами BLEConnectService та Artemisia для роботи з MQTT брокером
// - демо брокер broker.emqx.io,
// - прод брокер 13.48.148.89

class WeatherManager : ObservableObject {
    
    @Published var weatherData: Weather? //холдер погоди
    
    var connectionManager = BLEConnectService()
    
    var client:Artemisia = Artemisia.connect(host:  Constants.baseEndpointURL, port: Int32(Constants.baseEndpointPort) ?? 1883 , version: .v5)
    
    private var bag = Set<AnyCancellable>()
    
    init() {
        
        //на випадок оновлення адреси MQTT брокера в ConectionView
        NotificationCenter.default.addObserver(forName: Constants.MQQTNotification, object: nil, queue: nil) { notification in
            self.client = Artemisia.connect(host:  Constants.baseEndpointURL,port: Int32(Constants.baseEndpointPort) ?? 1883 , version: .v5)
        }
        
        connectionManager.$connectedPeripheral.sink { value in
            if let connectedPeripheral = value {
                self.reloadRemoteMTQQPublisher(connectedPeripheral: connectedPeripheral)
            }
        }.store(in: &bag)
        
    }
    
    func reloadRemoteMTQQPublisher(connectedPeripheral:WeatherPeripheralService) {
  
        
        //Підписуємось на зміни від переферійного датчику

        connectedPeripheral.weatherPublisher.sink(receiveCompletion: { completion in
            completionHandler: switch completion {
                default:
                break;
            }
        }, receiveValue: { weater in
            
                //Оновлюємо дані погоди для паблішера, та публікуємо дані в MQTT брокер
                DispatchQueue.main.async {
                    self.weatherData = weater
                }
            
                if let temp = weater.temperature {
                    let r = self.client["weather/temperature"].publish(message: String(temp))
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
