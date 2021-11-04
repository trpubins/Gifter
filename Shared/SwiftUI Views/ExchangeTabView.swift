//
//  ExchangeTabView.swift
//  Shared (View)
//
//  Created by Tanner on 8/7/21.
//

import SwiftUI
import Foundation

struct ExchangeTabView: View {
    
    /// The gift exchange current selection provided by a parent View
    @EnvironmentObject var selectedGiftExchange: GiftExchange
    
    /// The alert controller provided by a parent View
    @EnvironmentObject var alertController: AlertController
    
    /// Object encapsulating various state variables provided by a parent View
    @EnvironmentObject var triggers: StateTriggers
    
    
    // MARK: Body
    
    var body: some View {
        
        VStack {
            HStack {
                Text("Gift Exchange")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding([.top, .leading])
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(selectedGiftExchange.date.dayOfWeek), \(selectedGiftExchange.date, formatter: Date.formatMonthDay)")
                    if selectedGiftExchange.hasDatePassed() {
                        Text("Completed")
                    } else {
                        Text("\(selectedGiftExchange.date.daysUntil) days rem")
                    }
                }
                .padding([.top, .leading, .trailing])
            }  // end HStack
            HStack {
                VStack(alignment: .leading) {
                    if selectedGiftExchange.areGiftersMatched {
                        Text("Gifters matched: Yes")
                    } else {
                        Text("Gifters matched: No")
                    }
                    let emailStatus = selectedGiftExchange.getEmailStatus()
                    if emailStatus == .Sent {
                        Text("Email status: Sent (All)")
                    } else if emailStatus == .Unsent {
                        Text("Email status: Unsent (All)")
                    } else {
                        Text("Email status: Unsent (1 or more)")
                    }
                }
                .padding()
                
                Spacer()
            }
            Spacer()
            // place add gifter button if not enough gifters to match
            if selectedGiftExchange.gifters.count < 2 {
                Text("Not enough gifters to begin the exchange!")
                    .multilineTextAlignment(.center)
                addGifterButton()
            }
            // otherwise, display elements for matching gifters
            else {
                if selectedGiftExchange.areGiftersMatched {
                    //
                    // TODO: Show / hide matching results per settings
                    //
                    VStack {
                        ExchangeMatchingView()
                            .environmentObject(selectedGiftExchange)
                        matchGiftersButton()
                    }
                } else {
                    Text("The gifters in this exchange have not yet been matched!")
                        .multilineTextAlignment(.center)
                    matchGiftersButton()
                }
            }
            
            Spacer()
        } // end VStack
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { logAppear(title: "ExchangeTabView") }
        
    }
    
    
    // MARK: Sub Views
    
    /**
     A button that matches the gifters in the exchange.
     
     - Returns: A Button View.
     */
    @ViewBuilder
    func matchGiftersButton() -> some View {
        let label = Label("Match Gifters", systemImage: "arrow.left.arrow.right")
        if #available(iOS 15.0, *) {
            Button(action: { matchGifters() }) {
                label
            }
            .tint(.accentColor)
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .padding()
        } else {
            // fallback on earlier versions
            Button(action: { matchGifters() }) {
                label
            }
            .padding()
        }
    }
    
    /**
     A button that adds a gifter.
     
     - Returns: A Button View.
     */
    @ViewBuilder
    func addGifterButton() -> some View {
        if #available(iOS 15.0, *) {
            Button(action: { addGifter() }) {
                Label("Add Gifter", systemImage: "plus")
            }
            .tint(.accentColor)
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .padding()
        } else {
            // fallback on earlier versions
            Button(action: { addGifter() }) {
                Label("Add Gifter", systemImage: "plus")
            }
            .padding()
        }
    }
    
    
    // MARK: Model Functions
    
    /// Attempts to match the gifters in the selected gift exchange.
    func matchGifters() {
        logFilter("matching gifters...")
        var giftingMatrix = GiftingMatrix(giftExchange: selectedGiftExchange)
        
        if giftingMatrix.match() {
            logFilter("gifters successfully matched")
            selectedGiftExchange.areGiftersMatched = true
        } else {
            logFilter("a match could not be made, consider easing restrictions")
            selectedGiftExchange.areGiftersMatched = false
        }
        
        // persist changes
        PersistenceController.shared.saveContext()
        
        // alert the user of the outcome
        self.alertController.info = AlertInfo(
            id: .GiftExchangeMatching,
            alert: Alerts.giftExchangeMatchingAlert(matchingSuccess: selectedGiftExchange.areGiftersMatched)
        )
    }
    
    /// Triggers a sheet for adding a new gifter and changes the tab selection to the Gifters Tab.
    func addGifter() {
        logFilter("add gifter")
        triggers.isAddGifterFormShowing = true
    }
    
}

struct ExchangeTabView_Previews: PreviewProvider {
    
    static var previewGiftExchange1: GiftExchange? = nil
    static let previewGiftExchange2: GiftExchange = GiftExchange(context: PersistenceController.shared.context)
    static let previewAlertController = AlertController()

    struct ExchangeTabView_Preview: View {
        let previewGifters = getPreviewGifters()
        
        init() {
            ExchangeTabView_Previews.previewGiftExchange1 = GiftExchange(context: PersistenceController.shared.context)
            
            for gifter in previewGifters {
                ExchangeTabView_Previews.previewGiftExchange1!.addGifter(gifter)
            }
        }
        
        var body: some View {
            ExchangeTabView()
        }
    }
    
    static var previews: some View {
        // 1st preview
        NavigationView {
            ExchangeTabView_Preview()
                .environmentObject(previewGiftExchange1!)
                .environmentObject(previewAlertController)
        }
        // 2nd preview
        NavigationView {
            ExchangeTabView()
                .environmentObject(previewGiftExchange2)
                .environmentObject(previewAlertController)
        }
    }
    
}
