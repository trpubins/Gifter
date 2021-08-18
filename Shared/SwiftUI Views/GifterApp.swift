//
//  GifterApp.swift
//  Shared (App)
//
//  Created by Tanner on 7/16/21.
//

import SwiftUI

/**
 The entrance point for the Gifter application.
 
 This follows the App structure for iOS 14.  We don't need to push the viewContext of the singleton PersistenceController
 into the environment of the views because the managed object context is made available globally through a static property
 in the PersistenceController struct.
 
 As suggested here (https://developer.apple.com/forums/thread/650876) we do watch for changes to the Scene.
 */
@main
struct GifterApp: App {
    
    /// For tracking the phase (state) of the application
    @Environment(\.scenePhase) private var scenePhase
    
    /// The user settings
    @StateObject var giftExchangeSettings = UserSettings()
    
    var body: some Scene {
        
        WindowGroup {
            
            if giftExchangeSettings.idList.count >= 1 {
                MainView()
                    .environmentObject(giftExchangeSettings)
            } else {
                GiftExchangeFormView(formType: "New")
                    .environmentObject(giftExchangeSettings)
            }
            
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
                case .active:
                    print("app active")
                case .inactive:
                    print("app inactive")
                case .background:
                    print("app background")
                    PersistenceController.shared.saveContext()
                @unknown default:
                    print("app unknown phase")
            }
        }
        
    }
    
}
