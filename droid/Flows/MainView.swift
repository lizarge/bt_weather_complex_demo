//
//  ContentView.swift
//  droid
//
//  Created by ankudinov aleksandr on 25.06.2025.
//

import SwiftUI
import Combine

// Таб представлення с локальних та "віддалених" датчиків
// Оскільки це центральний екран програми він володіє WeatherManager (бізнес логіка), Також тут показуємо помилки, якщо вони виникають

struct MainView: View {
    
    @State private var selectedIndex: Int = 0
    @State private var showSettings: Bool = false
    
    @State private var error: WError?
    
    @StateObject var weatherManager = WeatherManager()
    
    @State var bag = Set<AnyCancellable>()
    
    var body: some View {
        ZStack {
            VStack {
                TabView(selection: $selectedIndex) {
                    NavigationStack() {
                        SensorView(weatherManager: weatherManager)
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
                    }) {
                        
                        if weatherManager.connectionManager.connectedPeripheral != nil {
                            Image(systemName: "link")
                                .resizable()
                                .renderingMode(.template).foregroundColor(.white)
                                .frame(width: 40, height: 40)
                        } else {
                            ProgressView(label: {
                                Text("Tap To Connect").foregroundColor(.white)
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
            ConnectionView(bleService: weatherManager.connectionManager)
                .presentationBackground(.ultraThinMaterial)
        }
        .alert(item: $error, content: { error in
            Alert(
                title: Text("Erorr"),
                message: Text(error.customMessage),
                dismissButton: .default(Text("Okay"))
            )
        })
        .onAppear() {
            weatherManager.connectionManager.$error.sink { error in
                self.error = error
            }.store(in: &bag)
        }
    }
}

#Preview {
    MainView()
}
