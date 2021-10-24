//
//  SettingsTabView.swift
//  Shared (View)
//
//  Created by Tanner on 8/7/21.
//

import SwiftUI

struct SettingsTabView: View {
    
    /// The gift exchange user settings provided by a parent View
    @EnvironmentObject var giftExchangeSettings: UserSettings
    
    
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
                // Gift Exchange settings
                Section(header: Text("Gift Exchange Settings"),
                        footer: Text("Hides the gift exchange results after gifters have been matched when toggled on.")) {
                    Toggle("Hide results", isOn: $giftExchangeSettings.hideResults)
                        .onChange(of: giftExchangeSettings.hideResults) { toggleValue in
                            logFilter("Gift Exchange Settings -> Hide results: \(toggleValue)")
                            PersistenceController.shared.saveContext()
                        }
                }
                // Gifter settings
                Section(header: Text("Gifter Settings"),
                        footer: Text("Automatically restrict gifters from matching in consecutive gift exchanges when toggled on.")) {
                    Toggle("Auto restrictions", isOn: $giftExchangeSettings.autoRestrictions)
                        .onChange(of: giftExchangeSettings.autoRestrictions) { toggleValue in
                            logFilter("Gifter Settings -> Auto restrictions: \(toggleValue)")
                            PersistenceController.shared.saveContext()
                        }
                }
            }  // end Form
            
            Spacer()
        }  // end VStack
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { logAppear(title: "SettingsTabView") }
    }
}

struct SettingsTabView_Previews: PreviewProvider {
    
    static let previewUserSettings: UserSettings = getPreviewUserSettings()

    static var previews: some View {
        NavigationView {
            SettingsTabView()
                .environmentObject(previewUserSettings)
        }
    }
    
}

