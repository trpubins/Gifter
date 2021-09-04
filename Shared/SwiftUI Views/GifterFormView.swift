//
//  GifterFormView.swift
//  Shared (View)
//
//  Created by Tanner on 8/29/21.
//

import SwiftUI


struct GifterFormView: View {
    
    /// Binds our View to the presentation mode so we can dismiss the View when we need to
    @Environment(\.presentationMode) var presentationMode
    
    /// The gift exchange current selection provided by a parent View
    @EnvironmentObject var selectedGiftExchange: GiftExchange
    
    /// Object encapsulating various state variables provided by a parent View
    @EnvironmentObject var triggers: StateTriggers
    
    /// The gift exchange form data whose properties are bound to the UI form
    @ObservedObject var data: GifterFormData
    
    /// State variable for determining if the save button is disabled
    @State private var isSaveDisabled: Bool = true
    
    /// State variable for determining if the delete alert is showing
    @State private var isDeleteAlertShowing: Bool = false
    
    /// Describes the type of gifter form this is
    let formType: FormType
    
    /**
     Initializes the form view instance members.
     
     - Parameters:
        - formType: Describes the type of gifter form
        - data: Optionally, provide data from an existing Gifter
     */
    init(formType: FormType, data: GifterFormData = GifterFormData()) {
        self.formType = formType
        self.data = data
    }
    
    var body: some View {
        
        let formName = "\(formType) Gifter"
        
        VStack {
            
            HStack {
                Text(formName)
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding([.top, .leading])
                Spacer()
            }
            
            Form {
                Section(header: Text("Gifter Info")) {
                    TextField("Name", text: $data.name)
                        .validation(data.nameValidation)
                    TextField("Email Address", text: $data.email)
                        .validation(data.emailValidation)
                }
                // insert add gifter button when a new gifter is being added
                if isNewForm() {
                    Button(action: { addNewGifter() }, label: {
                        HStack {
                            Label("Add Gifter", systemImage: "person.badge.plus")
                        }
                    })
                        .disabled(self.isSaveDisabled)
                } else {
                    // insert delete button if in edit mode
                    if #available(iOS 15.0, *) {
                        Button(role: .destructive, action: { deleteGifter() }, label: {
                            Text("Delete Gifter")
                                .frame(maxWidth: .infinity, alignment: .center)
                        })
                    } else {
                        // fallback on earlier versions
                        Button(action: { deleteGifter() }, label: {
                            Text("Delete Gifter")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.red)
                        })
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
            logAppear(title: "GifterFormView")
            // the data.allValidation property requires at least one message from
            // each publisher before it can publish it’s own message. in Edit mode,
            // we pre-populate the form with data provided at initialization.
            // so here, we assign the name field to itself in order to publish the
            // name field but keeping its value the same
            if formType == .Edit {
                self.data.name = self.data.name
            }
        }
//        .alert(isPresented: $isDeleteAlertShowing) {
//            Alerts.gifterDeleteAlert(gifter: gifter, selectedGiftExchange: selectedGiftExchange)
//        }
        
    }  // end body
    
    /// Adds the gifter to the selected gift exchange and to persistent storage.
    func addNewGifter() {
        #if os(iOS)
        hideKeyboard()
        #endif
        
        let gifter = Gifter.add(using: data)
        selectedGiftExchange.addGifter(gifter)
        commitDataEntry()
        logFilter("adding gifter: \(gifter.toString())")
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
            let gifter = Gifter.update(using: data)
            commitDataEntry()
            logFilter("saving gifter: \(gifter.toString())")
        })
            .disabled(self.isSaveDisabled)
    }
    
    /// Triggers an alert for deleting the currently selected gift exchange.
    func deleteGifter() {
        logFilter("delete gifter")
        self.isDeleteAlertShowing = true
    }
    
    /// Save the Gifter in CoreData, send user to Gifters Tab and dismiss the view.
    func commitDataEntry() {
        PersistenceController.shared.saveContext()
        triggers.selectedTab = TabNum.GiftersTab.rawValue
        presentationMode.wrappedValue.dismiss()
        logFilter("gifters count: \(selectedGiftExchange.gifters.count)")
    }
    
    /**
     Evaluates a logical expression to determine if the form is for adding a new gifter.
     
     - Returns: `true` if the form is for a new gifter, `false` if not.
     */
    func isNewForm() -> Bool {
        return (formType == .Add)
    }
    
}

struct GifterFormView_Previews: PreviewProvider {
    
    static let previewGiftExchange: GiftExchange = GiftExchange(context: PersistenceController.shared.context)
    
    static var previews: some View {
        // 1st preview
        NavigationView {
            GifterFormView(
                formType: FormType.Edit,
                data: GifterFormData(name: "Santa", email: "yohoho@northpole.com")
            )
                .environmentObject(previewGiftExchange)
        }
        // 2nd preview
        NavigationView {
            GifterFormView(formType: FormType.Add)
                .environmentObject(previewGiftExchange)
        }
    }
}
