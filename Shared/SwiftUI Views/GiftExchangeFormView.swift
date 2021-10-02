//
//  GiftExchangeFormView.swift
//  Shared (View)
//
//  Created by Tanner on 8/8/21.
//

import SwiftUI

struct GiftExchangeFormView: View {
    
    /// Binds our View to the presentation mode so we can dismiss the View when we need to
    @Environment(\.presentationMode) var presentationMode
    
    /// The gift exchange user settings provided by a parent View
    @EnvironmentObject var giftExchangeSettings: UserSettings
    
    /// The gift exchange current selection provided by a parent View
    @EnvironmentObject var selectedGiftExchange: GiftExchange
    
    /// The gift exchange form data whose properties are bound to the UI form
    @ObservedObject var data: GiftExchangeFormData
    
    /// State variable for determining if the save button is disabled
    @State private var isSaveDisabled: Bool = true
    
    /// State variable for determining if the delete alert is showing
    @State private var isDeleteAlertShowing: Bool = false
    
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
    
    
    // MARK: Body
    
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
                    nameTextField()
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
                if isNewForm(formType) {
                    Button(action: { startExchanging() }, label: {
                        HStack {
                            Label("Start Exchanging!", systemImage: "gift")
                        }
                    })
                    .disabled(self.isSaveDisabled)
                } else {
                    // insert delete exchange button if there is more than 1 gift exchange
                    if giftExchangeSettings.hasMultipleGiftExchanges() {
                        deleteButton()
                    }
                }
            }  // end Form
            .navigationTitle(String(stringLiteral: "\(formType)"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { cancelButton() }
                ToolbarItem(placement: .confirmationAction) {
                    // only an Edit form shall have the save button in the toolbar
                    if !isNewForm(formType) { saveButton() }
                }
            }
            .onReceive(data.allValidation) { validation in
                if isNewForm(formType) {
                    self.isSaveDisabled = !validation.isSuccess
                } else {
                    // form data needs to change in order to enable save button
                    if (validation.isSuccess && data.hasChanged(comparedTo: selectedGiftExchange)) {
                        self.isSaveDisabled = false
                    } else {
                        self.isSaveDisabled = true
                    }
                }
            }
            
        }  // end VStack
        .onAppear {
            logAppear(title: "GiftExchangeFormView")
            // the data.allValidation property requires at least one message from
            // each publisher before it can publish it’s own message. in Edit mode,
            // we pre-populate the form with data provided at initialization.
            // so here, we assign the data fields to itself in order to publish the
            // fields but keeping their values the same
            if !isNewForm(formType) {
                self.data.name = self.data.name
                self.data.date = self.data.date
                self.data.emoji = self.data.emoji
            }
        }
        .alert(isPresented: $isDeleteAlertShowing) {
            Alerts.giftExchangeDeleteAlert(giftExchange: selectedGiftExchange, giftExchangeSettings: giftExchangeSettings, mode: presentationMode)
        }
        
    }  // end body
    
    
    // MARK: Sub Views
    
    /**
     A field for capturing the name of the gift exchange. Validation occurs differently based on the
     form type.
     
     - Returns: The name text field with a validation modifier.
     */
    @ViewBuilder
    func nameTextField() -> some View {
        let textField = TextField("Name", text: $data.name)
        
        // drop the first publisher element for a new form so the field
        // is not invalidated before the user has a chance to type
        if isNewForm(formType) {
            textField
                .disableAutocorrection(true)
                .validation(data.nameValidation(dropFirst: true))
        } else {
            textField
                .disableAutocorrection(true)
                .validation(data.nameValidation(dropFirst: false))
        }
    }
    
    /**
     A Cancel button that dismisses the view.
     
     - Returns: A Button View.
     */
    @ViewBuilder
    func cancelButton() -> some View {
        Button("Cancel", action: {
            logFilter("cancelled action")
            presentationMode.wrappedValue.dismiss()
        })
    }
    
    /**
     A Save button that commits the form data.
     
     - Returns: A Button View.
     */
    @ViewBuilder
    func saveButton() -> some View {
        Button("Save", action: {
            let exchange = GiftExchange.update(using: data)
            logFilter("saving gift exchange: \(exchange.toString())")
            commitDataEntry()
            logFilter("idList count: \(giftExchangeSettings.idList.count)")
        })
            .disabled(self.isSaveDisabled)
    }
    
    /**
     A Delete button that deletes a gift exchange.
     
     - Returns: A Button View.
     */
    @ViewBuilder
    func deleteButton() -> some View {
        let text = Text("Delete Gift Exchange")
        
        if #available(iOS 15.0, *) {
            Button(role: .destructive, action: { deleteGiftExchange() }, label: {
                text
                    .frame(maxWidth: .infinity, alignment: .center)
            })
        } else {
            // fallback on earlier versions
            Button(action: { deleteGiftExchange() }, label: {
                text
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.red)
            })
        }
    }
    
    
    // MARK: Model Functions
    
    /// Adds the gift exchange to persistent storage and the new gift exchange id to the user settings.
    /// The gift exchange can commence.
    func startExchanging() {
        #if os(iOS)
        hideKeyboard()
        #endif
        
        let exchange = GiftExchange.add(using: data)
        commitDataEntry()
        logFilter("adding gift exchange: \(exchange.toString())")

        // updating the UserSettings object must occur last since UserSettings
        // property is being observed in the top-level GifterApp to change/refresh Views
        giftExchangeSettings.addGiftExchangeId(id: exchange.id)
        logFilter("idList count: \(giftExchangeSettings.idList.count)")
    }
    
    /// Triggers an alert for deleting the currently selected gift exchange.
    func deleteGiftExchange() {
        logFilter("delete gift exchange")
        self.isDeleteAlertShowing = true
    }
    
    /// Save the GiftExchange in CoreData and dismiss the view.
    func commitDataEntry() {
        PersistenceController.shared.saveContext()
        presentationMode.wrappedValue.dismiss()
    }
    
}

struct GiftExchangeFormView_Previews: PreviewProvider {
    
    static let previewUserSettings: UserSettings = getPreviewUserSettings()
    static let previewGiftExchange: GiftExchange = GiftExchange(context: PersistenceController.shared.context)

    struct EditGiftExchangeFormView_Preview: View {
        init() {
            GiftExchangeFormView_Previews.previewGiftExchange.name = "Zohan"
            GiftExchangeFormView_Previews.previewGiftExchange.emoji = emojis.first!
        }
        var body: some View {
            NavigationView {
                GiftExchangeFormView(
                    formType: FormType.Edit,
                    data: GiftExchangeFormData(giftExchange: GiftExchangeFormView_Previews.previewGiftExchange)
                )
                    .environmentObject(GiftExchangeFormView_Previews.previewUserSettings)
                    .environmentObject(GiftExchangeFormView_Previews.previewGiftExchange)
            }
        }
    }
    
    static var previews: some View {
        // 1st preview
        EditGiftExchangeFormView_Preview()
        // 2nd preview
        GiftExchangeFormView(formType: FormType.New)
    }
}
