//
//  droidApp.swift
//  droid
//
//  Created by ankudinov aleksandr on 25.06.2025.
//

import SwiftUI
import UIKit
import Combine


@main
struct droidApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

class AppDelegate : UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}



