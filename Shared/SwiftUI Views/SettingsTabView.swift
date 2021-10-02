//
//  SettingsTabView.swift
//  Shared (View)
//
//  Created by Tanner on 8/7/21.
//

import SwiftUI

struct SettingsTabView: View {
    
    /// The gift exchange current selection provided by a parent View
    @EnvironmentObject var selectedGiftExchange: GiftExchange
    
    var body: some View {
        VStack {
            Text("This is the SettingsTabView")
        }
        .onAppear { logAppear(title: "SettingsTabView") }
        
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    
    static let previewGiftExchange: GiftExchange = GiftExchange(context: PersistenceController.shared.context)
    
    static var previews: some View {
        NavigationView {
            SettingsTabView()
                .environmentObject(previewGiftExchange)
        }
    }
    
}

