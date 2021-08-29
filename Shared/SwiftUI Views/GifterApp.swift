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
                MainView(withId: giftExchangeSettings.selectedId!)  // force unwrap since we know the settings holds at least 1 id
                    .environmentObject(giftExchangeSettings)
            } else {
                GiftExchangeFormView(formType: FormType.New, data: GiftExchangeFormData(christmasDay: true))
                    .environmentObject(giftExchangeSettings)
            }
            
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
                case .active:
                    logFilter("app active")
                case .inactive:
                    logFilter("app inactive")
                case .background:
                    logFilter("app background")
                    PersistenceController.shared.saveContext()
                @unknown default:
                    logFilter("app unknown phase")
            }
        }
        
    }
    
}
