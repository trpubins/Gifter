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
    var triggers: StateTriggers = StateTriggers()
    
    /// State variable for determining if the gift exchange completed alert is showing
    @State private var isGiftExchangeCompletedAlertShowing: Bool = false
    
    /**
     Initializes the MainView by pulling out of CoreData the GiftExchange object as specified by the id.
     
     - Parameters:
        - id: The id used to identify the selected gift exchange
     */
    init(withId id: UUID) {
        self.selectedGiftExchange = GiftExchange.get(withId: id)
        
        // present the alert if the gift exchange's date has passed
        if self.selectedGiftExchange.date < Date.today {
            self._isGiftExchangeCompletedAlertShowing = State(initialValue: true)
        }
    }
    
    var body: some View {
        #if os(iOS)
        MainViewIOS(mainViewTabs: getMainViewData())
            .alert(isPresented: $isGiftExchangeCompletedAlertShowing) {
                Alerts.giftExchangeCompletedAlert(self.selectedGiftExchange)
            }
            .environmentObject(selectedGiftExchange)
            .environmentObject(triggers)
        #else
        MainViewMacOS(mainViewTabs: getMainViewData())
            .alert(isPresented: $isGiftExchangeCompletedAlertShowing) {
                Alerts.giftExchangeCompletedAlert(self.selectedGiftExchange)
            }
        #endif
    }
    
}

struct MainView_Previews: PreviewProvider {
    
    static let previewUserSettings: UserSettings = getPreviewUserSettings()
    
    static var previews: some View {
        MainView(withId: UUID())
            .environmentObject(previewUserSettings)
    }
    
}
