//
//  MainView.swift
//  Shared (Model)
//
//  Created by Tanner on 8/10/21.
//

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

/// An enum that maps a tab view name to its tab number.
enum TabNum: Int {
    case ExchangeTab = 1        // first tab
    case GiftersTab = 2         // second tab
    case PreferencesTab = 3     // third tab
}

/**
 Generates an array of MainViewData used to populate the MainViews.
 
 - Returns: An array of MainViewData instances.
 */
func getMainViewData() -> [MainViewData] {
    return [
        MainViewData(
            dest: AnyView(ExchangeTabView()),
            tabNum: TabNum.ExchangeTab.rawValue,
            labelText: "Gift Exchange",
            imgName: "gift"
        ),
        MainViewData(
            dest: AnyView(GiftersTabView()),
            tabNum: TabNum.GiftersTab.rawValue,
            labelText: "Gifters",
            imgName: "person.2"
        ),
        MainViewData(
            dest: AnyView(PreferencesTabView()),
            tabNum: TabNum.PreferencesTab.rawValue,
            labelText: "Preferences",
            imgName: "gearshape"
        ),
    ]
}
