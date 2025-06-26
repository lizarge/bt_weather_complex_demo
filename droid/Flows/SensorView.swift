//
//  SensorView.swift
//  droid
//
//  Created by ankudinov aleksandr on 25.06.2025.
//

import SwiftUI

struct SensorView: View {
    
    @StateObject var weatherManager = WeatherManager()
    @StateObject private var bleService = BLEConnectService.shared
    
    var body: some View {
        VStack{
            
            Spacer().frame(height: 100)
           
            ClockView()
            
            Spacer()
            
            HStack {
                WeatherText(label: weatherManager.weatherData?.temperature)
                    .font(.system(size: 200))
                    .foregroundStyle(.white)
                Spacer()
            }.padding(50)
            
            HStack {
                WeatherText(label: weatherManager.weatherData?.humidity)
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
                Image("humidity")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(.white).frame(width: 50, height: 50)
                Spacer()
                WeatherText(label: weatherManager.weatherData?.pressure)
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
                    .foregroundStyle(.white)
                Image("wind")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                
            }.padding(50)
                .background(.white.opacity(0.2))
                .cornerRadius(80)
                .padding(.horizontal, 50)
            
            Spacer().frame(height: 40)
                
        }
        .onChange(of: bleService.connectedPeripheral) { _ in
            weatherManager.updateSuscribtion()
        }
        .backgrounded()
    }
}

#Preview {
    SensorView()
}
