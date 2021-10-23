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
            }
            Spacer()
            if selectedGiftExchange.gifters.count < 2 {
                Text("Not enough gifters to begin the exchange!")
                    .multilineTextAlignment(.center)
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
            } else {
                Text("Show button to Run Exchange")
            }
            
            Spacer()
        } // end VStack
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { logAppear(title: "ExchangeTabView") }
        
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
