//
//  BLEService.swift
//  droid
//
//  Created by ankudinov aleksandr on 25.06.2025.
//

import Foundation
import CoreBluetooth
import Combine
import SwiftUI


class BLEConnectService : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    
    static let shared = BLEConnectService()
    
    @MainActor @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var error: WError?
    @Published  var connectedPeripheral: WeatherPeripheralService?
    
    private var centralManager: CBCentralManager?
    private var bag = Set<AnyCancellable>()
    
    private override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .global())
    }
    
    func connect(to peripheral: CBPeripheral) {
        centralManager?.connect(peripheral, options: nil)
    }
    
    func disconnect() {
        if let peripheral = connectedPeripheral?.peripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
            connectedPeripheral = nil
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        let service = WeatherPeripheralService(peripheral: peripheral)
        
        peripheral.delegate = service
        peripheral.discoverServices(nil)

        DispatchQueue.main.async {
            self.connectedPeripheral = service
        }
        
        self.connectedPeripheral?.weatherPublisher.sink(receiveCompletion: { completion in
            completionHandler: switch completion {
            case .finished:
                print("Weather data stream finished.")
            case .failure(let error):
                print("Error receiving weather data: \(error)")
                self.error = WError(error)
                self.disconnect()
            }
        }, receiveValue: { weater in
    
        }).store(in: &self.bag)
    }
    
    func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral){
        DispatchQueue.main.async {
            self.error = WError("Connection Event Did Occur")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        DispatchQueue.main.async {
            self.error = WError(error)
        }
    }
    
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral)
    {
        DispatchQueue.main.async {
            self.error = WError("Connection Event Did Occur")
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        DispatchQueue.main.async {
            self.connectedPeripheral = nil
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        } else {
            DispatchQueue.main.async {
                self.error = WError("Bluetooth is not powered on or available.")
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
   
        DispatchQueue.main.async {
            if !self.discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
                self.discoveredPeripherals.append(peripheral)
            }
        }
    }
   
}
