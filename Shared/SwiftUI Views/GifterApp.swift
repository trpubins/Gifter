//
//  GifterApp.swift
//  Shared (App)
//
//  Created by Tanner on 7/16/21.
//

import SwiftUI

/**
 The entrance point for the Gifter application.
 
 This follows the new App structure for iOS 14.  It pushes the viewContext of the singleton PersistenceController
 into the environment of the MainView -- this makes sure that all @FetchRequests from the managed object context will work.
 
 As suggested here: https://developer.apple.com/forums/thread/650876
 
 we also watch for changes to the Scene.
 */
@main
struct GifterApp: App {
    
    /// For tracking the phase (state) of the application
    @Environment(\.scenePhase) private var scenePhase
    
    /// The user settings
    @StateObject var giftExchangeSettings = UserSettings()
    
    /// Managed object context for the application's CoreData store
    let moc = PersistenceController.shared.container.viewContext
    
    var body: some Scene {
        
        WindowGroup {
            
            if giftExchangeSettings.idSelected != nil {
                mainView()
                    .environment(\.managedObjectContext, moc)
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
                    saveContext(context: moc)
                @unknown default:
                    print("app unknown phase")
            }
        }
        
    }
    
    /**
     Obtains the proper MainView based on the OS target.
     
     - Returns: A MainView struct conforming to the View protocol.
     */
    func mainView() -> some View {
        #if os(iOS)
        return MainViewIOS()
        #else
        return MainViewMacOS()
        #endif
    }
    
}
