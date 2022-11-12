//
//  ToolbarMenuView.swift
//  Shared (View)
//
//  Created by Tanner on 8/23/21.
//

import SwiftUI

struct ToolbarMenuView: View {
    
    /// The gift exchange user settings provided by a parent View
    @EnvironmentObject var giftExchangeSettings: UserSettings
    
    /// The gift exchange current selection provided by a parent View
    @EnvironmentObject var selectedGiftExchange: GiftExchange
    
    /// The alert controller provided by a parent View
    @EnvironmentObject var alertController: AlertController
    
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
    
    
    // MARK: Body
    
    var body: some View {
        Menu {
            // show the other gift exchanges if they exist
            if self.giftExchangeSettings.hasMultipleGiftExchanges() {
                ForEach(self.otherGiftExchanges) { exchange in
                    Button(action: { changeGiftExchange(exchange) }, label: {
                        Text(exchange.toString())
                    })
                }
                Divider()
            }
            Button(action: { editGiftExchange() }) {
                Label("Edit Gift Exchange", systemImage: "pencil")
            }
            Button(action: { addGiftExchange() }) {
                Label("Add Gift Exchange", systemImage: "plus")
            }
            // only show Delete button if there is more than 1 gift exchange
            if self.giftExchangeSettings.hasMultipleGiftExchanges() {
                deleteGiftExchangeButton()
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
    
    
    // MARK: Sub Views
    
    /**
     A Delete button that deletes a gift exchange.
     
     - Returns: A Button View.
     */
    @ViewBuilder
    func deleteGiftExchangeButton() -> some View {
        let label = Label("Delete Gift Exchange", systemImage: "trash")
        
        if #available(iOS 15.0, *) {
            Button(role: .destructive, action: { deleteGiftExchange() }, label: {
                label
            })
        } else {
            // fallback on earlier versions
            Button(action: { deleteGiftExchange() }, label: {
                label
                    .foregroundColor(.red)
            })
        }
    }
    
    
    // MARK: ViewModel Functions
    
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
        self.alertController.info = AlertInfo(
            id: .DeleteGiftExchange,
            alert: Alerts.giftExchangeDeleteAlert(giftExchange: selectedGiftExchange, giftExchangeSettings: giftExchangeSettings)
        )
    }
    
    /**
     Change the selected gift exchange to the specified gift exchange.
     
     - Parameters:
        - giftExchange: The gift exchange to make selected
     */
    func changeGiftExchange(_ giftExchange: GiftExchange) {
        logFilter("changing selected gift exchange to: \(giftExchange.toString())")
        self.giftExchangeSettings.changeSelectedGiftExchangeId(id: giftExchange.id)
    }
    
}

struct ToolbarMenuView_Previews: PreviewProvider {
    
    static let previewUserSettings: UserSettings = getPreviewUserSettings()
    static var previewGiftExchange: GiftExchange = GiftExchange(context: PersistenceController.shared.context)
    static let previewAlertController = AlertController()
    static let previewTriggers = StateTriggers()

    static var previews: some View {
        NavigationView {
            VStack {
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ToolbarMenuView(unselectedIds: previewUserSettings.unselectedIdList)
                        .environmentObject(previewUserSettings)
                        .environmentObject(previewGiftExchange)
                        .environmentObject(previewAlertController)
                        .environmentObject(previewTriggers)
                }
            }
        }  // end NavigationView
    }
    
}
