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
                    EmptyView()
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
    
    /// Matches the gifters in the selected gift exchange.
    func matchGifters() {
        logFilter("matching gifters...")
    }
    
    /// Triggers a sheet for adding a new gifter and changes the tab selection to the Gifters Tab.
    func addGifter() {
        logFilter("add gifter")
        triggers.isAddGifterFormShowing = true
    }
    
}

struct ExchangeTabView_Previews: PreviewProvider {
    
    static let previewGiftExchange1: GiftExchange = GiftExchange(context: PersistenceController.shared.context)
    static var previewGiftExchange2: GiftExchange? = nil
    
    struct ExchangeTabView_Preview: View {
        let previewGifters = getPreviewGifters()
        
        init() {
            ExchangeTabView_Previews.previewGiftExchange2 = GiftExchange(context: PersistenceController.shared.context)
            
            for gifter in previewGifters {
                ExchangeTabView_Previews.previewGiftExchange2!.addGifter(gifter)
            }
        }
        
        var body: some View {
            ExchangeTabView()
        }
    }
    
    static var previews: some View {
        // 1st preview
        ExchangeTabView()
            .environmentObject(previewGiftExchange1)
        // 2nd preview
        NavigationView {
            ExchangeTabView_Preview()
                .environmentObject(previewGiftExchange2!)
        }
    }
    
}
