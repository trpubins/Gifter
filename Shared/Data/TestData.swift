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
 
 - Returns: A UserSettings object that can be used in a preview.
 */
func getPreviewUserSettings() -> UserSettings {
    let previewUserSettings = UserSettings()
    previewUserSettings.addGiftExchangeId(id: UUID())
    return previewUserSettings
}


