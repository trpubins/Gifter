//
//  MainView.swift
//  Shared (View)
//
//  Created by Tanner on 8/17/21.
//

import SwiftUI

struct MainView: View {
    
    /// The gift exchange user settings provided by a parent View
    @EnvironmentObject var giftExchangeSettings: UserSettings
    
    /// Object encapsulating various state variables
    @ObservedObject var triggers: StateTriggers
    
    /// The gift exchange current selection
    var selectedGiftExchange: GiftExchange
    
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
        mainView()
            // gift exchange completed alert
            .alert(isPresented: .init(
                get: { triggers.isGiftExchangeCompletedAlertShowing },
                set: { triggers.isGiftExchangeCompletedAlertShowing = $0 }
            )) {
                Alerts.giftExchangeCompletedAlert(self.selectedGiftExchange)
            }
            // delete gift exchange alert
            .alert(isPresented: .init(
                get: { triggers.isDeleteGiftExchangeAlertShowing },
                set: { triggers.isDeleteGiftExchangeAlertShowing = $0 }
            )) {
                Alerts.giftExchangeDeleteAlert(giftExchange: selectedGiftExchange, giftExchangeSettings: giftExchangeSettings)
            }
            .environmentObject(selectedGiftExchange)
            .environmentObject(triggers)
    }
    
    /**
     The proper main view based on the OS.
     
     - Returns: The OS-specific main view.
     */
    func mainView() -> some View {
        #if os(iOS)
        MainViewIOS(mainViewTabs: getMainViewData())
        #else
        MainViewMacOS(mainViewTabs: getMainViewData())
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
