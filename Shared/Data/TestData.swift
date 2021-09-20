//
//  TestData.swift
//  Shared (Data)
//
//  Created by Tanner on 8/5/21.
//

import Foundation
import CoreData


/**
 Makes a UserSettings object and injects a gift exchange id for use in a preview.
 
 - Returns: A UserSettings object.
 */
func getPreviewUserSettings() -> UserSettings {
    let previewUserSettings = UserSettings()
    previewUserSettings.addGiftExchangeId(id: UUID())
    return previewUserSettings
}

/**
 Makes a Gifter object array for use in a preview.
 
 - Returns: A Gifter object array.
 */
func getPreviewGifters() -> [Gifter] {
    let names = [
        "David",
        "Debbie",
        "Taylor",
        "Amanda",
        "Tanner",
        "Molly",
        "Trey",
        "Larissa"
    ]
    var gifters: [Gifter] = []
    for name in names {
        let gifter = Gifter(context: PersistenceController.shared.context)
        gifter.name = name
        gifters.append(gifter)
    }
    return gifters
}


