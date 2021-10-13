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
    let testGifters = [
        [
            "name": "Tanner",
            "email": "t.pubins@icloud.com"
        ],
        [
            "name": "Molly",
            "email": "tmpubins@icloud.com"
        ],
        [
            "name": "Taylor",
            "email": "trpubins@asu.edu"
        ],
        [
            "name": "Trey",
            "email": "tanner.pubins@biola.edu"
        ],
    ]

    var tanner: Gifter? = nil
    var molly: Gifter? = nil
    
    var gifters: [Gifter] = []
    for testData in testGifters {
        // convert the test dict into form data
        let data = GifterFormData()
        
        if let name = testData["name"] {
            data.name = name
        } else {
            data.name = "Unknown gifter"
        }
        
        if let email = testData["email"] {
            data.email = email
        } else {
            data.email = "Unkown email"
        }
        
        // initialize a gifter from the form data
        let gifter = Gifter.update(using: data)
        gifters.append(gifter)
        
        if data.name == "Tanner" {
            tanner = gifter
        } else if data.name == "Molly" {
            molly = gifter
        }
        
    }
    
    tanner!.addRestrictedId(id: molly!.id)
    molly!.addRestrictedId(id: tanner!.id)
    
    return gifters
}


