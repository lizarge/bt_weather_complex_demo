//
//  Cell.swift
//  droid
//
//  Created by ankudinov aleksandr on 25.06.2025.
//

import SwiftUI

struct WeatherLabel: View {
    
    var title: String = "Remote"
    var value: Int?
    var imageName:String? = "wind"
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack {
                
                Text(title).font(.system(size: 70))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text( value != nil ? "\(value ?? 0)" : "-")
                    .font(.system(size: 70))
                    .foregroundStyle(.white)
                
                if let imageName = imageName {
                    Image(imageName)
                        .renderingMode(.template)
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 35, height: 30)
                        .padding(.bottom,12)
                        .padding(.leading,-8)
                } else {
                    Text("°")
                        .font(.system(size: 70))
                        .foregroundStyle(.white)
                        .frame(width: 35, height: 35)
                }
                
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.white)
                
        }.frame(height: 80)
    }
}

#Preview {
    WeatherLabel().backgrounded()
}
