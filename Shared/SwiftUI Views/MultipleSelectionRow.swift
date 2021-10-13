//
//  MultipleSelectionRow.swift
//  Shared (View)
//
//  Created by Tanner on 10/5/21.
//

import SwiftUI

struct MultipleSelectionRow: View {
    
    /// The title of the row
    var title: String
    
    /// Determines if the row is selected or not
    @State var isSelected: Bool = false
    
    /// Determines if the row is disabled or not
    var isDisabled: Bool = false
    
    /// An action handler to perform upon clicking the row
    var action: () -> Void
    
    
    // MARK: Body
    
    var body: some View {
        Button(action: {
            self.isSelected.toggle()
            self.action()
        }) {
            HStack {
                Text(self.title)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
        .disabled(isDisabled)
        // systemGray4 is equivalent to the disabled gray
        .foregroundColor(isDisabled ? Color(.systemGray4) : .primary)
    }
}

struct MultipleSelectionRow_Previews: PreviewProvider {
    static let previewGifters = getPreviewGifters()
    
    static var previews: some View {
        List {
            ForEach(previewGifters, id: \.self) { gifter in
                // select rows that don't start with the letter "T"
                if gifter.name.starts(with: "T") {
                    MultipleSelectionRow(title: gifter.name, isSelected: false, action: {})
                } else {
                    MultipleSelectionRow(title: gifter.name, isSelected: true, action: {})
                }
            }
        }
    }
}
