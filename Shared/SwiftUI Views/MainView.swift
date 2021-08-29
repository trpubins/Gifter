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
    
    /**
     Initializes the MainView by pulling out of CoreData the GiftExchange object as specified by the id.
     
     - Parameters:
        - id: The id used to identify the selected gift exchange
     */
    init(withId id: UUID) {
        self.selectedGiftExchange = GiftExchange.get(withId: id)
    }
    
    var body: some View {
        #if os(iOS)
        MainViewIOS(mainViewTabs: getMainViewData())
            .environmentObject(selectedGiftExchange)
            .environmentObject(triggers)
        #else
        MainViewMacOS(mainViewTabs: getMainViewData())
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
