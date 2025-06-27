//
//  ConnectionView.swift
//  droid
//
//  Created by ankudinov aleksandr on 25.06.2025.
//

import SwiftUI
import CoreBluetooth

//UI для керування підключенням до периферійних пристроїв та адреси MQTT брокера
struct ConnectionView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var host: String = Constants.baseEndpointURL
    @State private var port: String = Constants.baseEndpointPort
    @State private var isPressed = false
    
    @StateObject var bleService:BLEConnectService
    
    @State var selectedPeripheral: CBPeripheral?
    
    var body: some View {
        VStack {
            
            Text("Select Peripheral").font(.system(size: 30)).foregroundColor(.white).padding(.top, 20)
            
            List(bleService.discoveredPeripherals, id: \.identifier) { peripheral in
                
                HStack {
                    
                    Button(action: {
                        // Підключення до вибраного периферійного пристрою
                        
                        bleService.disconnect()
                        
                        bleService.connect(to: peripheral)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            dismiss()
                        }
                        
                        selectedPeripheral = peripheral
                    }) {
                        Text(peripheral.name ?? "Unknown Peripheral").font(.system(size: 30)).foregroundColor(.white)
                    }
                }
                .padding(.bottom, 10)
                .listRowBackground( selectedPeripheral == peripheral ? Color.red.opacity(0.5) : Color.clear )
            }
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .roundBorder()
            
            Text("MQTT Broker").font(.system(size: 30)).foregroundColor(.white).padding(.top, 20)
            
            HStack {
       
                TextField("MQTT Host", text: $host)
                    .font(.system(size: 30)).foregroundColor(.white)
                Text(":")
                    .font(.system(size: 30)).foregroundColor(.white)
                TextField("MQTT Port", text: $port)
                    .font(.system(size: 30)).foregroundColor(.white)
                
            }.roundBorder()
            
            HStack {
                Spacer()
                Button(action: {
                    
                    //Оскільки це демо проєкт використовуємо NotificationCenter для того щоб оновити дані в RemoteView та WeatherManager, в нормальному додатку не буде окремих єкземплярів для Artemisia
                    
                    Constants.baseEndpointURL = host
                    Constants.baseEndpointPort = port

                    NotificationCenter.default.post(name: Constants.MQQTNotification, object: nil)
                    
                    dismiss()
                }) {
                    Text("Apply")
                        .roundBorder().foregroundColor(.white)
                    
                }.padding()
            }

        }
    }
}

#Preview {
    ConnectionView( bleService: BLEConnectService())
}
