//
//  StateTriggers.swift
//  StateTriggers
//
//  Created by Tanner on 8/27/21.
//

import Foundation


/// Class for holding several state variables that trigger different application behaviors and View
/// functions such as sheets and alerts.
/// All instance members are published variables and the class conforms to ObservableObject.
class StateTriggers: ObservableObject {
    
    
    // MARK: SwiftUI Views Triggers
    
    /// Triggers the tab selection, which is the application's primary means of navigation
    @Published var selectedTab: Int = TabNum.ExchangeTab.rawValue
    
    
    // MARK: GiftExchange Triggers
    
    /// Triggers a sheet for adding a new gift exchange
    @Published var isAddGiftExchangeFormShowing: Bool = false
    
    /// Triggers a sheet for editing an existing gift exchange
    @Published var isEditGiftExchangeFormShowing: Bool = false
    
    /// Triggers an alert for deleting a gift exchange
    @Published var isDeleteGiftExchangeAlertShowing: Bool = false
    
    /// Triggers an alert for when a gift exchange date has passed
    @Published var isGiftExchangeCompletedAlertShowing: Bool = false
    
    
    // MARK: Gifter Triggers

    /// Triggers a sheet for adding a new gifter
    @Published var isAddGifterFormShowing: Bool = false
    
    /// Triggers a sheet for editing an existing gifter
    @Published var isEditGifterFormShowing: Bool = false
    
    /// Triggers an alert for deleting a gifter
    @Published var isDeleteGifterAlertShowing: Bool = false
}
