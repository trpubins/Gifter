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

/// An array of dictionaries holding data relevant to the MainViews
let mainViewTabs = [
    MainViewData(
        dest: AnyView(ExchangeTabView()),
        tabNum: 1,
        labelText: "Gift Exchange",
        imgName: "gift"
    ),
    MainViewData(
        dest: AnyView(GiftersTabView()),
        tabNum: 2,
        labelText: "Gifters",
        imgName: "person.2"
    ),
    MainViewData(
        dest: AnyView(PreferencesTabView()),
        tabNum: 3,
        labelText: "Preferences",
        imgName: "gearshape"
    ),
]
