//
//  ToolbarMenuView.swift
//  ToolbarMenuView
//
//  Created by Tanner on 8/23/21.
//

import SwiftUI

struct ToolbarMenuView: View {
    
    /// The gift exchange user settings provided by a parent View
    @EnvironmentObject var giftExchangeSettings: UserSettings
    
    /// The gift exchange current selection provided by a parent View
    @EnvironmentObject var selectedGiftExchange: GiftExchange
    
    /// Local state to trigger a sheet for adding a new gift exchange
    @Binding var isAddGiftExchangeFormShowing: Bool
    
    /// Local state to trigger a sheet for editing an existing gift exchange
    @Binding var isEditGiftExchangeFormShowing: Bool
    
    var body: some View {
        Menu {
            Button(action: { editGiftExchange() }) {
                Label("Edit Gift Exchange", systemImage: "pencil")
            }
            Button(action: { addGiftExchange() }) {
                Label("Add Gift Exchange", systemImage: "plus")
            }
            Divider()
            Button(action: { other() }) {
                Text("🎁  Pubins 2021")
            }
            
        } label: {
            HStack {
                Text("\(selectedGiftExchange.emoji)").baselineOffset(2)
                Text("\(selectedGiftExchange.name) " + String(selectedGiftExchange.date.year))
                Image(uiImage: UIImage(named: "dropdown.arrow")!)
            }
        }
        .foregroundColor(.primary)
    }
    
    /// Triggers a sheet for adding a new gift exchange.
    func addGiftExchange() {
        print("add gift exchange")
        isAddGiftExchangeFormShowing = true
    }
    
    /// Triggers a sheet for editing the currenty selected gift exchange.
    func editGiftExchange() {
        print("edit gift exchange")
        isEditGiftExchangeFormShowing = true
    }
    
    /// TODO
    func other() {
        print("other")
    }
    
}

struct ToolbarMenuView_Previews: PreviewProvider {
    
    static let previewUserSettings: UserSettings = getPreviewUserSettings()
    static var previewGiftExchange: GiftExchange = GiftExchange(context: PersistenceController.shared.context)
    
    static var previews: some View {
        PreviewWrapper()
    }
    
    // we create a wrapper around the preview to pass @Binding objects
    struct PreviewWrapper: View {
        @State(initialValue: false) var isAddFormShowing: Bool
        @State(initialValue: false) var isEditFormShowing: Bool
        
        var body: some View {
            
            NavigationView {
                VStack {
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        ToolbarMenuView(
                            isAddGiftExchangeFormShowing: $isAddFormShowing,
                            isEditGiftExchangeFormShowing: $isEditFormShowing
                        )
                            .environmentObject(previewUserSettings)
                            .environmentObject(previewGiftExchange)
                    }
                }
            }  // end NavigationView

        }
    }
    
}
