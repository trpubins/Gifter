//
//  GifterApp.swift
//  Shared
//
//  Created by Tanner on 7/16/21.
//

import SwiftUI

@main
struct GifterApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
