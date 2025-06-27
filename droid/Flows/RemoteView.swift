//
//  RemoteView.swift
//  droid
//
//  Created by ankudinov aleksandr on 25.06.2025.
//

import SwiftUI
import Artemisia
import Combine

// Простий демонстраційний клас для підключення до MQTT брокера і відображення данних з нього, реалізовано оновленння адресси брокера через notification center

struct RemoteView: View {
    
    @State var temperature: Int?
    @State var humidity:  Int?
    @State var pressuer:  Int?
    
    //тут краще використовувати ObservableObject, але для простоти використаємо State
    @State var client:Artemisia = Artemisia.connect(host:  Constants.baseEndpointURL,port: Int32(Constants.baseEndpointPort) ?? 1883 , version: .v5)
    @State  private var bag = Set<AnyCancellable>()

    
    var body: some View {
        VStack{
            Spacer().frame(height: 100)
            
            ClockView()

            Spacer()
            
            VStack {
                
                WeatherLabel(title: "Temperature", value: temperature, imageName:nil).padding(50)
                WeatherLabel(title: "Humidity", value: humidity, imageName:"humidity").padding(50)
                WeatherLabel(title: "Pressure", value: pressuer, imageName:"wind").padding(50)
                
            }.background(.white.opacity(0.2))
                .cornerRadius(80)
                .padding(.horizontal, 50)
            
            Spacer().frame(height: 40)
    
        }
        .onAppear {
            
            self.updateMQTTBrokerReader()
        
            NotificationCenter.default.addObserver(forName: Constants.MQQTNotification, object: nil, queue: nil) { _ in
                self.updateMQTTBrokerReader()
            }
        }
        .backgrounded()
        
    }
    
    func updateMQTTBrokerReader() {
        client = Artemisia.connect(host:  Constants.baseEndpointURL,port: Int32(Constants.baseEndpointPort) ?? 1883 , version: .v5)
    
        self.client["weather/temperature"].sink {  (msg: String) in
            temperature = Int(msg)
        }.store(in: &bag)
        
        self.client["weather/humidity"].sink { (msg: String) in
            humidity = Int(msg)
        }.store(in: &bag)
        
        self.client["weather/pressure"].sink {  (msg: String) in
            pressuer = Int(msg)
        }.store(in: &bag)
    }
        
}

#Preview {
    RemoteView()
}
