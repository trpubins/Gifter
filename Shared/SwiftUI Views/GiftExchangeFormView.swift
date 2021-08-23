//
//  GiftExchangeLaunchView.swift
//  Shared (View)
//
//  Created by Tanner on 8/8/21.
//

import SwiftUI


/**
 An enumeration for describing a form.
 
 Enumerations include: .New, .Add, & .Edit
 */
enum FormType {
    case New
    case Add
    case Edit
}

struct GiftExchangeFormView: View {
    
    /// Binds our View to the presentation mode so we can dismiss the View when we need to
    @Environment(\.presentationMode) var presentationMode
    
    /// The gift exchange user settings provided by a parent View
    @EnvironmentObject var giftExchangeSettings: UserSettings
    
    /// The gift exchange form data whose properties are bound to the UI form
    @ObservedObject var data: GiftExchangeFormData
    
    /// State variable for determining if the save button is disabled
    @State var isSaveDisabled: Bool = true
    
    /// Describes the type of gift exchange form this is
    let formType: FormType
    
    /**
     Initializes the form view instance members.
     
     - Parameters:
        - formType: Describes the type of gift exchange form
        - data: Optionally, provide data from an existing Gift Exchange
     */
    init(formType: FormType, data: GiftExchangeFormData = GiftExchangeFormData()) {
        self.formType = formType
        self.data = data
    }
    
    var body: some View {
        
        let formName = "\(formType) Gift Exchange"

        VStack {
            
            HStack {
                Text(formName)
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding([.top, .leading])
                Spacer()
            }
            
            Form {
                Section(header: Text("Gift Exchange Info")) {
                    TextField("Name", text: $data.name)
                        .validation(data.nameValidation)
                    // SwiftUI bug: DatePicker causes app to throw warning when
                    // embedded inside a form. Ignore warning.
                    DatePicker(selection: $data.date, displayedComponents: [.date]) {
                        Text("Gift exchange date")
                    }
                    .validation(data.dateValidation)
                    
                }
                Section(header: Text("Emoji")) {
                    EmojiView(self.data.emoji)
                        .environmentObject(data)
                }
                // insert start exchanging button when a new gift exchange is being added
                if isNewForm() {
                    Button(action: { startExchanging() }, label: {
                        HStack {
                            Label("Start Exchanging!", systemImage: "gift")
                        }
                    })
                    .disabled(self.isSaveDisabled)
                }
            }
            .navigationTitle(String(stringLiteral: "\(formType)"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { cancelButton() }
                ToolbarItem(placement: .confirmationAction) {
                    // only an Edit form shall have the save button in the toolbar
                    if formType == .Edit { saveButton() }
                }
            }
            .onReceive(data.allValidation) { validation in
                self.isSaveDisabled = !validation.isSuccess
            }
            
        }  // end VStack
        .onAppear {
            logAppear(title: "GiftExchangeFormView")
            // the data.allValidation property requires at least one message from
            // each publisher before it can publish it’s own message. in Edit mode,
            // we pre-populate the form with data provided at initialization.
            // so here, we assign the name field to itself in order to publish the
            // name field but keeping its value the same
            if formType == .Edit {
                self.data.name = self.data.name
            }
        }
        
    }  // end body
    
    /**
     Adds the gift exchange id to the user settings so they can start the gift exchange.
     */
    func startExchanging() {
        #if os(iOS)
        hideKeyboard()
        #endif
        
        commitDataEntry()
    }
    
    /**
     A Cancel button that dismisses the view.
     
     - Returns: A Button View
     */
    func cancelButton() -> some View {
        Button("Cancel", action: {
            presentationMode.wrappedValue.dismiss()
        })
    }
    
    /**
     A Save button that commits the form data.
     
     - Returns: A Button View
     */
    func saveButton() -> some View {
        Button("Save", action: { commitDataEntry() })
            .disabled(self.isSaveDisabled)
    }
    
    
    /// From the form data, update and persist the CoreData entity, GiftExchange.
    func commitDataEntry() {
        let exchange: GiftExchange
        if isNewForm() {
            exchange = GiftExchange.addNewGiftExchange(using: data)
        } else {
            exchange = GiftExchange.update(using: data)
        }
        
        PersistenceController.shared.saveContext()
        presentationMode.wrappedValue.dismiss()
        
        // updating the UserSettings object must occur last since UserSettings
        // property is being observed in the top-level GifterApp to change/refresh Views
        if isNewForm() {
            giftExchangeSettings.addGiftExchangeId(id: exchange.id)
        } else {
            giftExchangeSettings.giftExchangeHasChanged()
        }
    }
    
    /**
    Evaluates a logical expression to determine if the form is for adding a new gift exchange.
     
    - Returns: `true` if the form is for a new gift exchange, `false` if not.
     */
    func isNewForm() -> Bool {
        return (formType == .New || formType == .Add)
    }
    
}

struct GiftExchangeLaunchView_Previews: PreviewProvider {
    static var previews: some View {
        // 1st preview
        NavigationView {
            GiftExchangeFormView(formType: FormType.Edit, data: GiftExchangeFormData(name: "Zohan", emoji: emojis.first!))
        }
        // 2nd preview
        GiftExchangeFormView(formType: FormType.New)
    }
}
