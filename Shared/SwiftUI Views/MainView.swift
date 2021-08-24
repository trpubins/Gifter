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
    
    /// Local state to trigger a sheet for adding a new gift exchange
    @State private var isAddGiftExchangeFormShowing = false
    
    /// Local state to trigger a sheet for editing an existing gift exchange
    @State private var isEditGiftExchangeFormShowing = false
    
    /**
     Initializes the MainView by pulling out of CoreData the GiftExchange object as specified by the id.
     
     - Parameters:
        - id: The id used to identify the selected gift exchange
     */
    init(id: UUID) {
        self.selectedGiftExchange = GiftExchange.object(withID: id, context: PersistenceController.shared.context) ?? GiftExchange(context: PersistenceController.shared.context)
    }
    
    var body: some View {
        #if os(iOS)
        MainViewIOS(
            isAddGiftExchangeFormShowing: $isAddGiftExchangeFormShowing,
            isEditGiftExchangeFormShowing: $isEditGiftExchangeFormShowing,
            mainViewTabs: getMainViewData()
        )
            .environmentObject(selectedGiftExchange)
        #else
        MainViewMacOS(mainViewTabs: getMainViewData())
        #endif
    }
    
}

struct MainView_Previews: PreviewProvider {
    
    static let previewUserSettings: UserSettings = getPreviewUserSettings()
    
    static var previews: some View {
        MainView(id: UUID())
            .environmentObject(previewUserSettings)
    }
    
}
