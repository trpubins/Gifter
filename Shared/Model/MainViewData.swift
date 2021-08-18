//
//  MainView.swift
//  Shared (Model)
//
//  Created by Tanner on 8/10/21.
//

import Foundation
import SwiftUI

/// Defines a structure to hold data in the MainViews that is OS-independent.
struct MainViewData {
    
    /// The destination View
    var dest: AnyView
    
    /// The tab number (only used if the encapsulating view is a TabView)
    var tabNum: Int
    
    /// The text for the label
    var labelText: String
    
    /// The system image name
    var imgName: String
    
}

/**
 Generates an array of MainViewData used to populate the MainViews.
 
 - Parameters:
    - settings: The GiftExchange settings
 
 - Returns: An array of MainViewData instances.
 */
func getMainViewData(_ settings: UserSettings) -> [MainViewData] {
    let giftExchangeId = settings.selectedId!

    return [
        MainViewData(
            dest: AnyView(ExchangeTabView(id: giftExchangeId)),
            tabNum: 1,
            labelText: "Gift Exchange",
            imgName: "gift"
        ),
        MainViewData(
            dest: AnyView(GiftersTabView(id: giftExchangeId)),
            tabNum: 2,
            labelText: "Gifters",
            imgName: "person.2"
        ),
        MainViewData(
            dest: AnyView(PreferencesTabView(id: giftExchangeId)),
            tabNum: 3,
            labelText: "Preferences",
            imgName: "gearshape"
        ),
    ]
}
