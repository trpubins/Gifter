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
                Section(header: Text("Restrictions"),
                        footer: Text("Automatically restrict gifters from matching in consecutive gift exchanges when toggled on.")) {
                    Toggle("Auto restrictions", isOn: $giftExchangeSettings.autoRestrictions)
                        .onChange(of: giftExchangeSettings.autoRestrictions) { toggleValue in
                            logFilter("Auto restrictions: \(toggleValue)")
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

