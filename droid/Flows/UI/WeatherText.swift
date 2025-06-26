//
//  WeatherText.swift
//  droid
//
//  Created by ankudinov aleksandr on 26.06.2025.
//

import SwiftUI

struct WeatherText: View {
    
     var label:Int?
    
    var body: some View {
        Text(label != nil ? "\(label!)" : "-")
    }
}

#Preview {
    WeatherText()
}
