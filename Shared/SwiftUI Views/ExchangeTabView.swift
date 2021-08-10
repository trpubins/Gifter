//
//  ExchangeTabView.swift
//  Shared (View)
//
//  Created by Tanner on 8/7/21.
//

import SwiftUI

struct ExchangeTabView: View {
    
    /// The gift exchange user settings
    @EnvironmentObject var giftExchangeSettings: UserSettings
    
    var body: some View {
        
        VStack {
            Text("This is the ExchangeTabView")
            Text(giftExchangeSettings.idSelected?.uuidString ?? "None")
            Button(action: { giftExchangeSettings.removeSelectedGiftExchangeId() }, label: {
                Text("Remove Selected ID")
            })
        }
        
    }
}

struct ExchangeTabView_Previews: PreviewProvider {
    static var previews: some View {
        let giftExchangeSettings = UserSettings()
        
        ExchangeTabView()
            .environmentObject(giftExchangeSettings)
    }
}
