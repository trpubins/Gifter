//
//  GiftExchangeLaunchView.swift
//  Shared (View)
//
//  Created by Tanner on 8/8/21.
//

import SwiftUI

struct GiftExchangeFormView: View {
    
    /// The gift exchange user settings
    @EnvironmentObject var giftExchangeSettings: UserSettings
    
    /// The gift exchange form data whose properties are bound to the UI form
    @ObservedObject var data = GiftExchangeFormData()
    
    /// State variable for determining if the save button is disabled
    @State var isSaveDisabled = true
    
    /// Identifies the type of form this is (e.g. a "New" form or a "Modify" form, etc.)
    let formType: String
    
    var body: some View {
        
        let formName = formType + " Gift Exchange"

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
                Button(action: { self.startExchanging() }, label: {
                    HStack {
                        if formType.contains("New") {
                            Label("Start Exchanging!", systemImage: "gift.fill")
                        } else {
                            Text("Save Exchange")
                        }
                    }
                })
                .disabled(self.isSaveDisabled)
            }
            .navigationTitle(formName)
            .onReceive(data.allValidation) { validation in
                self.isSaveDisabled = !validation.isSuccess
            }
            
        }  // end VStack
        
    }  // end body
    
    /**
     Adds the gift exchange id to the user settings so they can start the gift exchange.
     */
    func startExchanging() {
        giftExchangeSettings.addGiftExchangeId(id: data.id)
    }
    
}

struct GiftExchangeLaunchView_Previews: PreviewProvider {
    static var previews: some View {
        GiftExchangeFormView(formType: "New")
    }
}
