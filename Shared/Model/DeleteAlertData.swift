//
//  DeleteAlertData.swift
//  DeleteAlertData
//
//  Created by Tanner on 8/27/21.
//

import Foundation
import SwiftUI


/// A struct that helps generate alerts when the user is attempting to delete something.
struct DeleteAlert {

    
    // MARK: Static Functions
    
    /**
     Generates an alert and subsequent action if the user intends to delete the selected gift exchange.
     
     - Parameters:
        - selectedGiftExchange: The current gift exchange selection
        - giftExchangeSettings: The gift exchange user settings
     
     - Returns: A populated alert that deletes the selected gift exchange if the user presses the Delete button.
     */
    static func giftExchangeAlert(selectedGiftExchange: GiftExchange, giftExchangeSettings: UserSettings) -> Alert {
        return Alert(
            title: Text("Are you sure you want to delete this gift exchange?"),
            message: Text("This action cannot be undone"),
            primaryButton: .destructive(Text("Delete")) {
                logFilter("deleting gift exchange \(selectedGiftExchange.emoji) \(selectedGiftExchange.name)...")
                // first, delete the object from CoreData
                GiftExchange.delete(selectedGiftExchange)
                
                // second, remove the gift exchange id from the user config data
                giftExchangeSettings.removeSelectedGiftExchangeId()
            },
            secondaryButton: .cancel()
        )
    }

    /**
     Generates an alert and subsequent action if the user intends to delete the specified gifter.
     
     - Parameters:
        - gifter: The gifter to be deleted
     
     - Returns: A populated alert that deletes the specified gifter if the user presses the Delete button.
     */
    static func gifterAlert(_ gifter: Gifter) -> Alert {
        return Alert(
            title: Text("Are you sure you want to delete this gifter?"),
            message: Text("This action cannot be undone"),
            primaryButton: .destructive(Text("Delete")) {
                logFilter("deleting gifter \(gifter.name)...")
                // MARK: TODO
                // Delete object from CoreData
                
            },
            secondaryButton: .cancel()
        )
    }
}
