//
//  PeripheralService.swift
//  droid
//
//  Created by ankudinov aleksandr on 26.06.2025.
//

import Foundation
import Combine
import CoreBluetooth
import SwiftUI

class WeatherPeripheralService :NSObject, CBPeripheralDelegate {

    var weatherPublisher: AnyPublisher<Weather, WError> {
        weatherSubject.eraseToAnyPublisher()
    }
    
    private(set) var peripheral: CBPeripheral
    private let weatherSubject = PassthroughSubject<Weather, WError>()
    
    private var bag = Set<AnyCancellable>()
    private var characteristicsBag: [CBCharacteristic] = []
    
    private var currentWeather = Weather()
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        self.peripheral.delegate = self
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        guard handleError(error) else {
            return
        }
        
        if let weatherService = peripheral.services?.first(where: { $0.uuid.uuidString == Constants.BluetoothService.serviceUUID }) {
            peripheral.discoverCharacteristics(nil, for: weatherService) // Discover all characteristics
            
            self.startObserveWeather()
        } else {
            print("Propper Weather service not found")
            self.weatherSubject.send(completion: .failure( WError("Propper Weather service not found")))
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard handleError(error) else {
            return
        }
     
        if let characteristics = service.characteristics  {
            for characteristic in characteristics {
                if characteristic.uuid.uuidString == Constants.BluetoothService.BluetoothServiceChannels.temperatureChannel {
                    peripheral.setNotifyValue(true, for: characteristic)
                } else {
                    characteristicsBag.append(characteristic)
                }
            }
        }
    }
        
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard handleError(error) else {
            return
        }
        
        guard characteristic.value != nil else {
            return
        }
        
        if let value = characteristic.value?.withUnsafeBytes({
            (rawPtr: UnsafeRawBufferPointer) in
            return rawPtr.load(as: UInt32.self)
        }) {
            if characteristic.uuid.uuidString == Constants.BluetoothService.BluetoothServiceChannels.humidityChannel {
               print("humidity value: \(value)")
               currentWeather.humidity = Int(value)
            } else if characteristic.uuid.uuidString == Constants.BluetoothService.BluetoothServiceChannels.pressureChannel {
               currentWeather.pressure = Int(value)
               print("pressure value: \(value)")
            } else if characteristic.uuid.uuidString == Constants.BluetoothService.BluetoothServiceChannels.temperatureChannel {
                currentWeather.temperature = Int(value)
                print("temperature value: \(value)")
            }
            
            DispatchQueue.main.async {
                self.weatherSubject.send(self.currentWeather)
            }
        }
        
    }
    
    private func startObserveWeather(){
        Timer.publish(every: 3.0, on: .main, in: .default)
         .autoconnect()
         .sink { _ in
             self.characteristicsBag.forEach { characteristics in
                 self.peripheral.readValue(for: characteristics)
             }
         }.store(in: &bag)
    }
    
    private func handleError(_ error: Error?) -> Bool {
        
        if error == nil {
            return true
        }
        
        DispatchQueue.main.async {
            self.weatherSubject.send(completion: .failure( WError(error) ))
        }
        
        print("Error: \(error?.localizedDescription ?? "Unknown error")")
        
        return false
    }
    
}

