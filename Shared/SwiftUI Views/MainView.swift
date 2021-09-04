//
//  MainView.swift
//  Shared (View)
//
//  Created by Tanner on 8/17/21.
//

import SwiftUI

struct MainView: View {
    
    /// The gift exchange current selection
    var selectedGiftExchange: GiftExchange
    
    /// Object encapsulating various state variables
    var triggers: StateTriggers
    
    /**
     Initializes the MainView by pulling out of CoreData the GiftExchange object as specified by the id.
     Also, initializes the application state triggers and shows an alert if the gift exchange is completed.
     
     - Parameters:
        - id: The id used to identify the selected gift exchange
        - triggers: An object that holds several state variables that trigger different behaviors
     */
    init(withId id: UUID, and triggers: StateTriggers) {
        self.selectedGiftExchange = GiftExchange.get(withId: id)
        self.triggers = triggers
        
        // present the alert if the gift exchange's date has passed
        // and send user to the Exchange Tab
        if self.selectedGiftExchange.hasDatePassed() {
            self.triggers.isGiftExchangeCompletedAlertShowing = true
            self.triggers.selectedTab = TabNum.ExchangeTab.rawValue
        } else {
            self.triggers.isGiftExchangeCompletedAlertShowing = false
        }
    }
    
    var body: some View {
        #if os(iOS)
        MainViewIOS(mainViewTabs: getMainViewData())
            .alert(isPresented: .init(
                get: { triggers.isGiftExchangeCompletedAlertShowing },
                set: { triggers.isGiftExchangeCompletedAlertShowing = $0 }
            )) {
                Alerts.giftExchangeCompletedAlert(self.selectedGiftExchange)
            }
            .environmentObject(selectedGiftExchange)
            .environmentObject(triggers)
        #else
        MainViewMacOS(mainViewTabs: getMainViewData())
            .alert(isPresented: .init(
                get: { triggers.isGiftExchangeCompletedAlertShowing },
                set: { triggers.isGiftExchangeCompletedAlertShowing = $0 }
            )) {
                Alerts.giftExchangeCompletedAlert(self.selectedGiftExchange)
            }
        #endif
    }
    
}

struct MainView_Previews: PreviewProvider {
    
    static let previewUserSettings: UserSettings = getPreviewUserSettings()
    
    static var previews: some View {
        MainView(withId: UUID(), and: StateTriggers())
            .environmentObject(previewUserSettings)
    }
    
}
