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
    @State var isSaveDisabled: Bool
    
    /// Describes the type of gift exchange form this is
    let formType: FormType
    
    /**
     Initializes the form view and a state variable that determines whether or not the form can be saved.
     
     - Parameters:
        - formType: Describes the type of gift exchange form
        - data: Optionally, provide data from an existing Gift Exchange
     */
    init(formType: FormType, data: GiftExchangeFormData = GiftExchangeFormData()) {
        self.formType = formType
        self.data = data
        
        if formType == .Edit {
            // data is sure to be valid since this is existing data
            // any changes to the form data will still have to go through validation
            self._isSaveDisabled = State(initialValue: false)
        } else {
            // form is empty so the save state shall be disabled
            self._isSaveDisabled = State(initialValue: true)
        }
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
                // insert start exchanging button when a new gift exchange is being added
                if formType == .New || formType == .Add {
                    Button(action: { self.startExchanging() }, label: {
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
            .accentColor(.red)
            
        }  // end VStack
        .onAppear { logAppear(title: "GiftExchangeFormView") }
        
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
        GiftExchange.update(using: data)
        PersistenceController.shared.saveContext()
        presentationMode.wrappedValue.dismiss()
        // updating the UserSettings object must occur last since UserSettings
        // property is being observed in the top-level GifterApp to change/refresh Views
        giftExchangeSettings.addGiftExchangeId(id: data.id)
    }
    
}

struct GiftExchangeLaunchView_Previews: PreviewProvider {
    static var previews: some View {
        // 1st preview
        GiftExchangeFormView(formType: FormType.New)
        // 2nd preview
        NavigationView {
            GiftExchangeFormView(formType: FormType.Add)
        }
    }
}
