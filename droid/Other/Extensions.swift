//
//  Extensions.swift
//  droid
//
//  Created by ankudinov aleksandr on 25.06.2025.
//

import SwiftUI

// допоміжна фігня 
extension View {

    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
    
    @ViewBuilder func tintColor() -> some View {
        self.foregroundColor(Color("AccentColor"))
    }
    
    @ViewBuilder func backgrounded() -> some View {
        ZStack {
            Image("CoolBackgrounds").resizable()
            self
        }.ignoresSafeArea()
    }
    
    @ViewBuilder func roundBorder() -> some View {
        self.padding()
            .overlay(
                 RoundedRectangle(cornerRadius: 30)
                     .stroke(.white, lineWidth: 1)
             )
            .padding()
    }
}


