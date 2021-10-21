//
//  MultipleSelectionList.swift
//  Shared (View)
//
//  Created by Tanner on 10/5/21.
//

import SwiftUI

struct MultipleSelectionList: View {

    /// The gift exchange user settings as an observed object
    @ObservedObject var giftExchangeSettings: UserSettings
    
    /// The gifter form data whose properties are bound to the UI form
    @ObservedObject var data: GifterFormData
    
    /// State variable for determining if the first asterisk in the section footer is shown
    @State private var isFirstAsteriskShown: Bool = false
    
    /// State variable for determining if the second asterisk in the section footer is shown
    @State private var isSecondAsteriskShown: Bool = false
    
    /// The navigation title applied when this view is being embedded into a NavigationView
    let navTitle: String
    
    /// An array of gifters excluding the gifter associated with the form data
    let otherGifters: [Gifter]
    
    /**
     Initializes the selection list instance members.
     
     - Parameters:
        - settings: The gift exchange user settings
        - data: The form data representing the selected gifter
        - navTitle: The navigation title for the view
        - otherGifters: Array of gifters excluding the gifter associated with the form data
     */
    init(settings: UserSettings, data: GifterFormData, navTitle: String, otherGifters: [Gifter]) {
        self.giftExchangeSettings = settings
        self.data = data
        self.navTitle = navTitle
        self.otherGifters = otherGifters
        self._isFirstAsteriskShown = State(initialValue: firstAsteriskIsShown())
        self._isSecondAsteriskShown = State(initialValue: secondAsteriskIsShown())
    }
    
    
    // MARK: Body
    
    var body: some View {
        
        /// The gifter represented by this form (non-nil if previously committed to persistent store)
        let selectedGifter = Gifter.get(withId: self.data.id)
        
        List {
            Section(header: Text("Restricted gifters will not be matched as recipients of the gifter being edited."),
                    footer: dynamicFooter()) {
                ForEach(self.otherGifters) { gifter in
                    /// Shorthand to determine if a gifter is selected or not
                    let isSelected = self.data.restrictedIds.contains(gifter.id)
                    
                    // check if auto restrictions is on and if any of the other
                    // gifters were the previous recipient
                    if self.giftExchangeSettings.autoRestrictions && selectedGifter?.previousRecipientId == gifter.id {
                        MultipleSelectionRow(title: "\(gifter.name)*",
                                             isSelected: isSelected,
                                             isDisabled: true) {
                            // do nothing, row is disabled
                        }
                    }
                    // need at least one other gifter available in order to have a
                    // valid gift exchange, otherwise the gifter could not be matched
                    // with anyone
                    else if !isSelected && isOnlyOneGifterRem() {
                        MultipleSelectionRow(title: "\(gifter.name)**",
                                             isSelected: isSelected,
                                             isDisabled: true) {
                            // do nothing, row is disabled
                        }
                    } else {
                        MultipleSelectionRow(title: gifter.name,
                                             isSelected: isSelected,
                                             isDisabled: false) {
                            updateData(gifter)
                            self.isSecondAsteriskShown = secondAsteriskIsShown()
                        }
                    }
                }
            }  // end Section
            .textCase(nil)  // force the header text to be retain its original case
        }  // end List
        .navigationTitle(self.navTitle)
    }
    
    
    // MARK: Sub Views
    
    /**
     A dynamic section footer that changes based on the selections made in the list.

     - Returns: The footer as a view.
     */
    @ViewBuilder
    func dynamicFooter() -> some View {
        let asteriskFrameWidth: CGFloat = 15
        VStack(alignment: .leading) {
            if (self.isFirstAsteriskShown) {
                HStack(alignment: .top) {
                    Text("*")
                        .frame(width: asteriskFrameWidth)
                    Text("This gifter was matched in the previous exchange and is automatically restricted, see Settings tab.")
                }
            }
            if (self.isSecondAsteriskShown) {
                HStack(alignment: .top) {
                    Text("**")
                        .frame(width: asteriskFrameWidth)
                    Text("This gifter cannot be restricted or else a match cannot be made.")
                }
            }
        }
    }
    
    
    // MARK: Boolean Expressions
    
    /**
     Logical function to determine if the first asterisk in the section footer should be shown.
     
     - Returns: `true` if the asterisk should be shown, `false` otherwise.
     */
    func firstAsteriskIsShown() -> Bool {
        // get the gifter from the data if gifter exists
        guard let selectedGifter = Gifter.get(withId: self.data.id) else {
            return false
        }
        
        // ensure the property is not nil
        if let previousRecipientId = selectedGifter.previousRecipientId {
            // ensure the previous recipient is in the gift exchange
            if recipientExists(previousRecipientId) {
                // add recipient to restricted ids if auto restrictions is on
                if self.giftExchangeSettings.autoRestrictions {
                    self.data.addRestrictedId(previousRecipientId)
                    return true
                }
                // remove recipient from restricted ids if auto restrictions is off
                else {
                    self.data.removeRestrictedId(previousRecipientId)
                    return false
                }
            }
        }
        return false
    }
    
    /**
     Logical function to determine if the second asterisk in the section footer should be shown.
     
     - Returns: `true` if the asterisk should be shown, `false` otherwise.
     */
    func secondAsteriskIsShown() -> Bool {
        if isOnlyOneGifterRem() {
            return true
        } else {
            return false
        }
    }
    
    /**
     Determines if the specified recipient exists as one of the other gifters in the gift exchange.
     
     - Parameters:
        - recipientId: Identifier for the recipient (gifter)
     
     - Returns: `true` if the recipient exists as one of the other gifters, `false` otherwise.
     */
    func recipientExists(_ recipientId: UUID) -> Bool {
        for gifter in self.otherGifters {
            if gifter.id == recipientId {
                return true
            }
        }
        return false
    }
    
    /**
     Determines if there is only one gifter remaining (not restricted).
          
     - Returns: `true` if there is only one gifter remaining, `false` if there is more than one.
     */
    func isOnlyOneGifterRem() -> Bool {
        return self.data.restrictedIds.count >= self.otherGifters.count - 1
    }

    
    // MARK: Model Functions
    
    /**
     Updates the form data restrictions.
     
     - Parameters:
        - gifter: The gifter that has been selected or deselected
     */
    func updateData(_ gifter: Gifter) {
        // update the restrictedIds array property based on current selection
        if self.data.restrictedIds.contains(gifter.id) {
            self.data.restrictedIds.removeAll(where: { $0 == gifter.id })
        }
        else {
            self.data.restrictedIds.append(gifter.id)
        }
        
        // must reassign the GifterFormData property, restrictedIds, to itself in order to
        // trigger another willSet for the @Published property. The first time the property
        // is changed (above), the projected value is not updated and so the value does not
        // appear to have changed from the original form data. Without this reassignment,
        // the form's save button will not become properly enabled.
        // for more information on publishers emitting on willSet, see
        // https://forums.swift.org/t/is-this-a-bug-in-published/31292/49
        self.data.restrictedIds = self.data.restrictedIds
    }
    
}

struct MultipleSelectionList_Previews: PreviewProvider {
    
    static let previewUserSettings: UserSettings = getPreviewUserSettings()
    static var previewGiftExchange: GiftExchange? = nil
    static var previewFormData: GifterFormData = GifterFormData()
    
    struct MultipleSelectionList_Preview: View {
        let previewGifters = getPreviewGifters()
        
        init() {            
            MultipleSelectionList_Previews.previewGiftExchange = GiftExchange(context: PersistenceController.shared.context)
            
            for gifter in previewGifters {
                MultipleSelectionList_Previews.previewGiftExchange!.addGifter(gifter)
            }
            let selectedGifter = previewGifters.first!
            MultipleSelectionList_Previews.previewFormData = GifterFormData(gifter: selectedGifter)
        }
        
        var body: some View {
            let otherGifters = previewGiftExchange!.gifters.filter( {$0.id != previewFormData.id} )
            MultipleSelectionList(settings: previewUserSettings,
                                  data: previewFormData,
                                  navTitle: "Restrictions",
                                  otherGifters: otherGifters)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    static var previews: some View {
        NavigationView {
            MultipleSelectionList_Preview()
        }
    }
}
