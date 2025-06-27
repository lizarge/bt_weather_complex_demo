//
//  File.swift
//  droid
//
//  Created by ankudinov aleksandr on 26.06.2025.
//

import Foundation

// WError кастомні помилки 

class WError: Error, Identifiable {
    
    var customMessage: String
    
    init(_ error: Error?) {
        self.customMessage = error?.localizedDescription ?? "Unknown error"
    }
    
    init(_ message: String) {
        self.customMessage = message
    }
            
}
