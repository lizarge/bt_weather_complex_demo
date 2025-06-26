//
//  ConnectionView.swift
//  droid
//
//  Created by ankudinov aleksandr on 25.06.2025.
//

import SwiftUI

struct ConnectionView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var host: String = Constants.baseEndpointURL
    @State private var port: String = Constants.baseEndpointPort
    
    @StateObject private var bleService = BLEConnectService.shared
    
    var body: some View {
        VStack {
            
            Text("Select Peripheral").font(.system(size: 30)).foregroundColor(.white).padding(.top, 20)
            
            List(bleService.discoveredPeripherals, id: \.identifier) { peripheral in
                
                HStack {
                   
                    
                    Text(peripheral.name ?? "Unknown Peripheral").font(.system(size: 30)).foregroundColor(.white).onTapGesture {
                        bleService.connect(to: peripheral)
                        
                        dismiss()
                    }
                }
                .padding(.bottom, 10)
                .listRowBackground(Color.clear)
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
    ConnectionView()
}
