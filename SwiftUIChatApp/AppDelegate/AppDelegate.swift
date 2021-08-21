//
//  AppDelegate.swift
//  tec
//
//  Created by differenz147 on 25/06/21.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
        
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
         
        FirebaseApp.configure()

        return true
    }
}
