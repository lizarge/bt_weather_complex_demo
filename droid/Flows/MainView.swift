//
//  ContentView.swift
//  droid
//
//  Created by ankudinov aleksandr on 25.06.2025.
//

import SwiftUI

struct MainView: View {
    
    @State private var selectedIndex: Int = 0
    @State private var showSettings: Bool = false
    @StateObject private var bleService = BLEConnectService.shared
    
    var body: some View {
        ZStack {
            VStack {
                TabView(selection: $selectedIndex) {
                    NavigationStack() {
                        SensorView()
                    }
                    .tabItem {
                        Label("Local", systemImage: "thermometer.variable")
                    }
                    .tag(0)
             
                    NavigationStack() {
                        RemoteView()
                    }
                    .tabItem {
                        Label("Remote", systemImage: "link.icloud")
                    }
                    .tag(1)
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showSettings.toggle()
                        bleService.disconnect()
                    }) {
                        
                        if bleService.connectedPeripheral != nil {

                            Image(systemName: "link")
                                .resizable()
                                .renderingMode(.template).foregroundColor(.white)
                                .frame(width: 40, height: 40)
                        } else {
                            ProgressView(label: {
                                Text("Connect Here").foregroundColor(.white)
                            }).progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        }
                    }
                    .padding(.top, 30)
                    .padding(.trailing, 55)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showSettings) {
            ConnectionView()
                .presentationBackground(.ultraThinMaterial)
        }
        .alert(item: $bleService.error, content: { error in
            Alert(
                title: Text("Erorr"),
                message: Text(error.message),
                dismissButton: .default(Text("Okay"))
            )
        })
      
    }
}

#Preview {
    MainView()
}
