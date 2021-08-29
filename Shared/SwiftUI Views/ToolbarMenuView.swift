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
    
    /// Object encapsulating various state variables provided by a parent View
    @EnvironmentObject var triggers: StateTriggers
    
    /// An array of other (unselected) gift exchanges to which the user belongs
    private var otherGiftExchanges: [GiftExchange] = []
    
    /**
     Initializes the toolbar menu view.
     
     - Parameters:
        - unselectedIds: A list of ids mapping to unselected gift exchanges that are associated with the user
     */
    init(unselectedIds: [UUID]) {
        self.otherGiftExchanges = GiftExchange.objectArr(entity: GiftExchange.self, withIdArr: unselectedIds, context: PersistenceController.shared.context)
    }
    
    var body: some View {
        Menu {
            // only show Delete button if there is more than 1 gift exchange
            if self.giftExchangeSettings.hasMultipleGiftExchanges() {
                if #available(iOS 15.0, *) {
                    Button(role: .destructive, action: { deleteGiftExchange() }, label: {
                        Label("Delete Gift Exchange", systemImage: "trash")
                    })
                } else {
                    // fallback on earlier versions
                    Button(action: { deleteGiftExchange() }, label: {
                        Label("Delete Gift Exchange", systemImage: "trash")
                            .foregroundColor(.red)
                    })
                }
            }
            Button(action: { editGiftExchange() }) {
                Label("Edit Gift Exchange", systemImage: "pencil")
            }
            Button(action: { addGiftExchange() }) {
                Label("Add Gift Exchange", systemImage: "plus")
            }
            // show the other gift exchanges if they exist
            if self.giftExchangeSettings.hasMultipleGiftExchanges() {
                Divider()
                ForEach(self.otherGiftExchanges) { exchange in
                    Button(action: { changeGiftExchange(exchange) }, label: {
                        Text("\(exchange.emoji)   \(exchange.name)  " + String(exchange.date.year))
                    })
                }
            }
        } label: {
            HStack {
                Text("\(selectedGiftExchange.emoji)").baselineOffset(2)
                Text("\(selectedGiftExchange.name)")
                Text(String(selectedGiftExchange.date.year))
                Image(uiImage: UIImage(named: "dropdown.arrow")!)
            }
            .frame(maxWidth: UIScreen.screenWidth*3/5)
        }
        .foregroundColor(.primary)
    }
    
    /// Triggers a sheet for adding a new gift exchange.
    func addGiftExchange() {
        logFilter("add gift exchange")
        self.triggers.isAddGiftExchangeFormShowing = true
    }
    
    /// Triggers a sheet for editing the currenty selected gift exchange.
    func editGiftExchange() {
        logFilter("edit gift exchange")
        self.triggers.isEditGiftExchangeFormShowing = true
    }
    
    /// Triggers an alert for deleting the currently selected gift exchange.
    func deleteGiftExchange() {
        logFilter("delete gift exchange")
        self.triggers.isDeleteGiftExchangeAlertShowing = true
    }
    
    /**
     Change the selected gift exchange to the specified gift exchange.
     
     - Parameters:
        - giftExchange: The gift exchange to make selected
     */
    func changeGiftExchange(_ giftExchange: GiftExchange) {
        logFilter("changing selected gift exchange to: \(giftExchange.name)")
        giftExchangeSettings.changeSelectedGiftExchangeId(id: giftExchange.id)
    }
    
}

struct ToolbarMenuView_Previews: PreviewProvider {
    
    static let previewUserSettings: UserSettings = getPreviewUserSettings()
    static var previewGiftExchange: GiftExchange = GiftExchange(context: PersistenceController.shared.context)
    static let previewTriggers: StateTriggers = StateTriggers()

    static var previews: some View {
        NavigationView {
            VStack {
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ToolbarMenuView(unselectedIds: previewUserSettings.unselectedIdList)
                        .environmentObject(previewUserSettings)
                        .environmentObject(previewGiftExchange)
                        .environmentObject(previewTriggers)
                }
            }
        }  // end NavigationView
    }
    
}
