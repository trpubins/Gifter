//
//  PreferencesTabView.swift
//  Shared (View)
//
//  Created by Tanner on 8/7/21.
//

import SwiftUI

struct PreferencesTabView: View {
    
    @ObservedObject var selectedGiftExchange: GiftExchange
    
    init(id: UUID) {
        // here we use the giftExchangeSettings to initialize the
        // @FetchedResults for a GiftExchange
        self.selectedGiftExchange = GiftExchange.object(withID: id, context: PersistenceController.shared.context) ?? GiftExchange(context: PersistenceController.shared.context)
    }
    
    var body: some View {
        
        VStack {
            Text("This is the PreferencesTabView")
        }
        .onAppear { logAppear(title: "PreferencesTabView") }
        
    }
}

struct PreferencesTabView_Previews: PreviewProvider {
    
    static let previewUserSettings: UserSettings = getPreviewUserSettings()
    
    static var previews: some View {
        PreferencesTabView(id: previewUserSettings.selectedId!)
            .environmentObject(previewUserSettings)
    }
    
}

