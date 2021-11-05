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
    
    
    // MARK: Body
    
    var body: some View {
        
        VStack {
            HStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding([.top, .leading])
                Spacer()
            }  // end HStack
            Spacer()
            Form {
                // Gifter settings
                Section(header: Text("Gifter Settings"),
                        footer: Text("Automatically restrict gifters from matching in consecutive gift exchanges when toggled on.")) {
                    Toggle("Auto restrictions", isOn: $selectedGiftExchange.autoRestrictions)
                        .onChange(of: selectedGiftExchange.autoRestrictions) { toggleValue in
                            logFilter("Gifter Settings -> Auto restrictions: \(toggleValue)")
                            // update the restricted list based on the toggle state
                            if toggleValue {
                                addRestrictions()
                            } else {
                                removeRestrictions()
                            }
                            PersistenceController.shared.saveContext()
                        }
                }
            }  // end Form
            
            Spacer()
        }  // end VStack
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { logAppear(title: "SettingsTabView") }
    }
    
    
    // MARK: Model Functions
    
    /// Adds the previous recipient for each gifter as a restriction, as applicable.
    func addRestrictions() {
        for gifter in selectedGiftExchange.gifters {
            if let previousRecipientId = gifter.previousRecipientId {
                gifter.addRestrictedId(previousRecipientId)
            }
        }
    }
    
    /// Removes the previous recipient for each gifter as a restriction, as applicable.
    func removeRestrictions() {
        for gifter in selectedGiftExchange.gifters {
            if let previousRecipientId = gifter.previousRecipientId {
                gifter.removeRestrictedId(previousRecipientId)
            }
        }
    }
    
}

struct SettingsTabView_Previews: PreviewProvider {
    
    static let previewGiftExchange: GiftExchange = GiftExchange(context: PersistenceController.shared.context)

    struct SettingsTabView_Preview: View {
        let previewGifters = getPreviewGifters()
        
        init() {
            SettingsTabView_Previews.previewGiftExchange.autoRestrictions = true
        }
        
        var body: some View {
            SettingsTabView()
                .environmentObject(previewGiftExchange)
        }
    }
    
    static var previews: some View {
        NavigationView {
            SettingsTabView_Preview()
        }
    }
    
}

