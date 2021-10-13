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
    
    /// The gifter selection provided by a parent View
    @EnvironmentObject var selectedGifter: Gifter
    
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
    
    /// Holds a copy of the original gifter form data, which may be required to reset the gifter form
    let originalData: GifterFormData
    
    /**
     Initializes the form view instance members.
     
     - Parameters:
        - formType: Describes the type of gifter form
        - data: Optionally, provide data from an existing Gifter
     */
    init(formType: FormType, data: GifterFormData = GifterFormData()) {
        self.formType = formType
        self.data = data
        self.originalData = GifterFormData(formData: data)
    }
    
    
    // MARK: Body
    
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
                // Gifter Info
                Section(header: Text("Gifter Info")) {
                    nameTextField()
                    emailTextField()
                }
                
                // Wish Lists
                Section(header: Text("Wish Lists")) {
                    ForEach($data.wishLists) { $wishList in
                        HStack {
                            Button(
                                action: { data.deleteWishList($wishList) },
                                label: { Image(systemName: "minus.circle") }
                            )
                            wishListTextField($wishList)
                        }

                    }
                    Button(action: { data.addWishList() }, label: {
                        Text("Add Wish List")
                    })
                }
                
                // add Restrictions section if enough gifters are present
                if (isNewForm(formType) && selectedGiftExchange.gifters.count > 0) ||
                (selectedGiftExchange.gifters.count > 1) {
                    // Restrictions
                    let subHeading = "Restrictions"
                    Section(header: Text(subHeading)) {
                        NavigationLink(destination:
                                        MultipleSelectionList(navTitle: subHeading)
                                        .environmentObject(selectedGiftExchange)
                                        .environmentObject(data)
                        )
                        {
                            Text("Number of restrictions: \(data.restrictedIds.count)")
                        }
                    }
                }
                
                // insert add gifter button when a new gifter is being added
                if isNewForm(formType) {
                    Button(action: { addNewGifter() }, label: {
                        HStack {
                            Label("Add Gifter", systemImage: "person.badge.plus")
                        }
                    })
                        .disabled(self.isSaveDisabled)
                } else {
                    // insert delete button if in edit mode
                    deleteButton()
                }
            }  // end Form
            .navigationTitle(String(stringLiteral: "\(formType)"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
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
                    if (validation.isSuccess && data.hasChanged(comparedTo: selectedGifter)) {
                        self.isSaveDisabled = false
                    } else {
                        self.isSaveDisabled = true
                    }
                }
            }
            
        }  // end VStack
        .onAppear { logAppear(title: "GifterFormView") }
        .alert(isPresented: $isDeleteAlertShowing) {
            Alerts.gifterDeleteAlert(gifter: selectedGifter, selectedGiftExchange: selectedGiftExchange)
        }
        
    }  // end body
    
    
    // MARK: Sub Views
    
    /**
     A field for capturing the gifter's name. Validation occurs differently based on the
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
     A field for capturing the gifter's email. Validation occurs differently based on the
     form type.
     
     - Returns: The email text field with a validation modifier.
     */
    @ViewBuilder
    func emailTextField() -> some View {
        let textField = TextField("Email address", text: $data.email)
        
        // drop the first publisher element for a new form so the field
        // is not invalidated before the user has a chance to type
        if isNewForm(formType) {
            textField
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .validation(data.emailValidation(dropFirst: true))
        } else {
            textField
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .validation(data.emailValidation(dropFirst: false))
        }
    }
    
    /**
     A field for capturing a wish list url. Validation occurs differently based on the initial url string.
     
     - Parameters:
        - wishList: A binding to the wish list form field
     
     - Returns: A wish list text field with a validation modifier.
     */
    @ViewBuilder
    func wishListTextField(_ wishList: Binding<WishList>) -> some View {
        let textField = TextField("Website link or URL", text: wishList.url)
        
        // do not drop the first publisher element if the wishlist is part of
        // the original data but do so if the wishlist is newly added so the
        // text field is not invalidated before the user has a chance to type
        if originalData.wishLists.contains(wishList.wrappedValue) {
            textField
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .validation(data.wishListValidation(wishList.wrappedValue.id,
                                                    dropFirst: false))
        } else {
            textField
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .validation(data.wishListValidation(wishList.wrappedValue.id,
                                                    dropFirst: true))
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
            if !isNewForm(formType) {
                // need to reset the gifter form data to the original since this
                // form is called as a NavigationLink and not a sheet like the
                // GiftExchangeFormView
                data.resetForm(with: originalData)
            }
        })
    }
    
    /**
     A Save button that commits the form data.
     
     - Returns: A Button View.
     */
    @ViewBuilder
    func saveButton() -> some View {
        Button("Save", action: {
            let gifter = Gifter.update(using: data)
            commitDataEntry()
            logFilter("saving gifter: \(gifter.toString())")
        })
            .disabled(self.isSaveDisabled)
    }
    
    /**
     A Delete button that deletes a gifter.
     
     - Returns: A Button View.
     */
    @ViewBuilder
    func deleteButton() -> some View {
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
    
    
    // MARK: Model Functions
    
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
    
}

struct GifterFormView_Previews: PreviewProvider {
    
    static var previewGiftExchange: GiftExchange? = nil
    static var previewGifter: Gifter? = nil
    static var previewGifterFormData: GifterFormData = GifterFormData()
    
    struct EditGifterFormView_Preview: View {
        let previewGifters = getPreviewGifters()
        
        init() {
            GifterFormView_Previews.previewGifterFormData.name = "Santa"
            GifterFormView_Previews.previewGifterFormData.email = "yohoho@northpole.com"
            GifterFormView_Previews.previewGifterFormData.wishLists = [
                WishList(with: "presents.com/santa"),
                WishList(with: "https://bagz.org")
            ]
            
            GifterFormView_Previews.previewGifter = Gifter.update(using: GifterFormView_Previews.previewGifterFormData)
            
            GifterFormView_Previews.previewGiftExchange = GiftExchange(context: PersistenceController.shared.context)
            
            for gifter in previewGifters {
                GifterFormView_Previews.previewGiftExchange!.addGifter(gifter)
            }
        }
        
        var body: some View {
            GifterFormView(
                formType: FormType.Edit,
                data: GifterFormView_Previews.previewGifterFormData
            )
        }
    }
    
    static var previews: some View {
        // 1st preview
        NavigationView {
            EditGifterFormView_Preview()
                .environmentObject(previewGiftExchange!)
                .environmentObject(previewGifter!)
                .environmentObject(previewGifterFormData)
        }
        // 2nd preview
        NavigationView {
            GifterFormView(formType: FormType.Add)
                .environmentObject(previewGiftExchange!)
                .environmentObject(previewGifter!)
                .environmentObject(previewGifterFormData)
        }
    }
    
    
}
