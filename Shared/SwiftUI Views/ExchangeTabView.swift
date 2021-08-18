//
//  ExchangeTabView.swift
//  Shared (View)
//
//  Created by Tanner on 8/7/21.
//

import SwiftUI
import Foundation

struct ExchangeTabView: View {
    
    /// The gift exchange user settings provided by a parent View
    @EnvironmentObject var giftExchangeSettings: UserSettings
    
    @ObservedObject var selectedGiftExchange: GiftExchange
    
    init(id: UUID) {
        // here we use the giftExchangeSettings to initialize the
        // @FetchedResults for a GiftExchange
        self.selectedGiftExchange = GiftExchange.object(withID: id, context: PersistenceController.shared.context) ?? GiftExchange(context: PersistenceController.shared.context)
    }
    
    var body: some View {
        
        NavigationView {
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
                    Button(action: { }) {
                        Label("Add Gifter", systemImage: "plus")
                    }
                    .padding()

                } else {
                    Text("Show button to Run Exchange")
                }
                
                Spacer()
            }
            .accentColor(.red)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Menu {
                        Button(action: { edit() }) {
                            Label("Edit Gift Exchange", systemImage: "pencil")
                        }
                        Button(action: { add() }) {
                            Label("Add Gift Exchange", systemImage: "plus")
                        }
                        Divider()
                        Button(action: { other() }) {
                            Text("🎁  Pubins 2021")
                        }
                        
                    } label: {
                        Text("🎄").baselineOffset(2)
                        Text("\(selectedGiftExchange.name) " + String(selectedGiftExchange.date.year))
                        Image(uiImage: UIImage(named: "dropdown.arrow")!)
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .onAppear { logAppear(title: "ExchangeTabView") }
    }
    
    func edit() {
        print("edit")
    }
    
    func add() {
        print("add")
    }
    
    func other() {
        print("other")
    }
    
}

struct ExchangeTabView_Previews: PreviewProvider {
    
    static let previewUserSettings: UserSettings = getPreviewUserSettings()
    
    static var previews: some View {
        ExchangeTabView(id: previewUserSettings.selectedId!)
            .environmentObject(previewUserSettings)
    }
    
}
