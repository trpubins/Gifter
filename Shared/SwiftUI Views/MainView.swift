//
//  MainView.swift
//  Shared (View)
//
//  Created by Tanner on 8/17/21.
//

import SwiftUI

struct MainView: View {

    /// Controls the alert information at the app level
    @ObservedObject var alertController = AlertController()
    
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
        
        // present the gift exchange completed alert if the gift exchange's
        // date has passed and send user to the Exchange Tab
        if self.selectedGiftExchange.hasDatePassed() {
            self.alertController.info = AlertInfo(
                id: .GiftExchangeCompleted,
                alert: Alerts.giftExchangeCompletedAlert(self.selectedGiftExchange)
            )
            self.triggers.selectedTab = TabNum.ExchangeTab.rawValue
        }
        
        // https://developer.apple.com/forums/thread/673147
        // the below code is a hack for the SwiftUI bug mentioned in the above thread
        // the bug is that alert buttons do not take on the project's accent color
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "AccentColor")
    }
    
    
    // MARK: Body
    
    var body: some View {
        mainView()
            .environmentObject(selectedGiftExchange)
            .environmentObject(triggers)
            .environmentObject(alertController)
            .alert(item: $alertController.info, content: { info in
                info.alert
            })
    }
    
    
    // MARK: Sub Views
    
    /**
     The proper main view based on the OS.
     
     - Returns: The OS-specific main view.
     */
    @ViewBuilder
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
