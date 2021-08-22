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
    
    /// The gift exchange current selection
    var selectedGiftExchange: GiftExchange
    
    /// Local state to trigger a sheet for adding a new gift exchange
    @State private var isAddGiftExchangeFormShowing = false
    
    /// Local state to trigger a sheet for editing an existing gift exchange
    @State private var isEditGiftExchangeFormShowing = false
    
    /**
     Initializes the ExchangeTabView by pulling out of CoreData the GiftExchange object as specified by the id.
     
     - Parameters:
        - id: The id used to identify the selected gift exchange
     */
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
                    if #available(iOS 15.0, *) {
                        Button(action: { print("add gifter") }) {
                            Label("Add Gifter", systemImage: "plus")
                        }
                        .tint(.accentColor)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                        .padding()
                    } else {
                        // fallback on earlier versions
                        Button(action: { print("add gifter") }) {
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
            .toolbar {
                ToolbarItem(placement: .principal) {
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
            }
        } // end NavigationView
        .onAppear { logAppear(title: "ExchangeTabView") }
        .sheet(isPresented: $isAddGiftExchangeFormShowing) {
            getFormView(formType: FormType.Add)
        }
        .sheet(isPresented: $isEditGiftExchangeFormShowing) {
            getFormView(formType: FormType.Edit)
        }
    }
    
    /**
     Returns a form view that is configured with the provided formType.
     
     - Parameters:
        - formType: Describes the type of form to generate
     
     - Returns: A configured GiftExchangeFormView.
     */
    func getFormView(formType: FormType) -> some View {
        NavigationView {
            if formType == .Add {
                GiftExchangeFormView(formType: FormType.Add)
            } else if formType == .Edit {
                GiftExchangeFormView(formType: FormType.Edit, data: GiftExchangeFormData(giftExchange: selectedGiftExchange))
            }
        }
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

struct ExchangeTabView_Previews: PreviewProvider {
    
    static let previewUserSettings: UserSettings = getPreviewUserSettings()
    
    static var previews: some View {
        ExchangeTabView(id: previewUserSettings.selectedId!)
            .environmentObject(previewUserSettings)
    }
    
}
