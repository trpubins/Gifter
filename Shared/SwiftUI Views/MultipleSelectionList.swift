//
//  MultipleSelectionList.swift
//  Shared (View)
//
//  Created by Tanner on 10/5/21.
//

import SwiftUI

struct MultipleSelectionList: View {
    
    /// The gift exchange current selection provided by a parent View
    @EnvironmentObject var selectedGiftExchange: GiftExchange
    
    /// The gift exchange form data whose properties are bound to the UI form provided by a parent View
    @EnvironmentObject var data: GifterFormData
    
    /// The navigation title if this view is being embedded into a NavigationView
    let navTitle: String
    
    
    // MARK: Body
    
    var body: some View {
        /// An array of gifters excluding the gifter associated with the form data
        let otherGifters = self.selectedGiftExchange.gifters.filter({ $0.id != self.data.id })
        
        List {
            ForEach(otherGifters) { gifter in
                /// Shorthand to determine if a gifter is selected or not
                let isSelected = self.data.restrictedIds.contains(gifter.id)
                
                // need at least one other gifter available in order to have a
                // valid gift exchange, otherwise the gifter could not be matched with anyone
                if !isSelected && self.data.restrictedIds.count >= otherGifters.count - 1 {
                    MultipleSelectionRow(title: gifter.name,
                                         isSelected: isSelected,
                                         isDisabled: true) {
                        updateData(gifter)
                    }
                } else {
                    MultipleSelectionRow(title: gifter.name,
                                         isSelected: isSelected,
                                         isDisabled: false) {
                        updateData(gifter)
                    }
                }
            }
        }
        .navigationTitle(self.navTitle)
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
            MultipleSelectionList(navTitle: "Restrictions")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    static var previews: some View {
        NavigationView {
            MultipleSelectionList_Preview()
                .environmentObject(previewGiftExchange!)
                .environmentObject(previewFormData)
        }
    }
}
