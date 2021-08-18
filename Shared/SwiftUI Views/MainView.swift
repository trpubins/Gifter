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
    
    var body: some View {
        #if os(iOS)
        MainViewIOS(mainViewTabs: getMainViewData(giftExchangeSettings))
        #else
        MainViewMacOS(mainViewTabs: getMainViewData(giftExchangeSettings))
        #endif
    }
    
}

struct MainView_Previews: PreviewProvider {
    
    static let previewUserSettings: UserSettings = getPreviewUserSettings()

    static var previews: some View {
        MainView()
            .environmentObject(previewUserSettings)
    }
    
}
