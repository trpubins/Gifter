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
                    Text("\(selectedGiftExchange.date.daysUntil) days rem")
                }
                .padding([.top, .leading, .trailing])
            }
            Spacer()
            if selectedGiftExchange.gifters.count < 2 {
                Text("Not enough Gifters to begin the exchange!")
                if #available(iOS 15.0, *) {
                    Button(action: { logFilter("add gifter") }) {
                        Label("Add Gifter", systemImage: "plus")
                    }
                    .tint(.accentColor)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .padding()
                } else {
                    // fallback on earlier versions
                    Button(action: { logFilter("add gifter") }) {
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
    
}

struct ExchangeTabView_Previews: PreviewProvider {
    
    static let previewGiftExchange: GiftExchange = GiftExchange(context: PersistenceController.shared.context)
    
    static var previews: some View {
        NavigationView {
            ExchangeTabView()
                .environmentObject(previewGiftExchange)
        }
    }
    
}
