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
                } else {
                    // insert delete exchange button if there is more than 1 gift exchange
                    if giftExchangeSettings.hasMultipleGiftExchanges() {
                        if #available(iOS 15.0, *) {
                            Button(role: .destructive, action: { deleteGiftExchange() }, label: {
                                Text("Delete Gift Exchange")
                                    .frame(maxWidth: .infinity, alignment: .center)
                            })
                        } else {
                            // fallback on earlier versions
                            Button(action: { deleteGiftExchange() }, label: {
                                Text("Delete Gift Exchange")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(.red)
                            })
                        }
                    }
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
        .alert(isPresented: $isDeleteAlertShowing) {
            Alerts.giftExchangeDeleteAlert(giftExchange: selectedGiftExchange, giftExchangeSettings: giftExchangeSettings, mode: presentationMode)
        }
        
    }  // end body
    
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
    
    /**
     A Cancel button that dismisses the view.
     
     - Returns: A Button View
     */
    func cancelButton() -> some View {
        Button("Cancel", action: {
            logFilter("cancelled action")
            presentationMode.wrappedValue.dismiss()
        })
    }
    
    /**
     A Save button that commits the form data.
     
     - Returns: A Button View
     */
    func saveButton() -> some View {
        Button("Save", action: {
            let exchange = GiftExchange.update(using: data)
            logFilter("saving gift exchange: \(exchange.toString())")
            commitDataEntry()
            logFilter("idList count: \(giftExchangeSettings.idList.count)")
        })
            .disabled(self.isSaveDisabled)
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
    
    /**
    Evaluates a logical expression to determine if the form is for adding a new gift exchange.
     
    - Returns: `true` if the form is for a new gift exchange, `false` if not.
     */
    func isNewForm() -> Bool {
        return (formType == .New || formType == .Add)
    }
    
}

struct GiftExchangeFormView_Previews: PreviewProvider {
    
    static let previewUserSettings: UserSettings = getPreviewUserSettings()
    static let previewGiftExchange: GiftExchange = GiftExchange(context: PersistenceController.shared.context)

    static var previews: some View {
        // 1st preview
        NavigationView {
            GiftExchangeFormView(
                formType: FormType.Edit,
                data: GiftExchangeFormData(name: "Zohan", emoji: emojis.first!)
            )
                .environmentObject(previewUserSettings)
                .environmentObject(previewGiftExchange)
        }
        // 2nd preview
        GiftExchangeFormView(formType: FormType.New)
    }
}
