//
//  EmojiView.swift
//  Shared (View)
//
//  Created by Tanner on 8/19/21.
//

import SwiftUI

/// A list of emojis to display and choose from
let emojis = ["🎁", "🎄", "🎅🏻", "🪅", "🧧", "🎉", "🎊","🎈"]

struct EmojiView: View {
    
    /// The gift exchange form data whose properties are bound to the UI form
    @EnvironmentObject var data: GiftExchangeFormData
    
    /// The array index associated with the selected emoji
    @State var emojiSelection: Int
    
    /**
     Initializes the EmojiView with the specified emoji. Converts the selection into an array index.
     
     - Parameters:
        - emoji: Optionally, the emoji to make the current selection
     */
    init(_ emoji: String = emojis.first!) {
        guard let selection = emojis.firstIndex(of: emoji) else {
            self.emojiSelection = 0  // select the first emoji in the list
            return
        }
        self.emojiSelection = selection
    }
    
    var body: some View {
        VStack {
            
            let nElementsPerRow = 4  // we specify how many per row
            let nRows = emojis.count/nElementsPerRow
            
            ForEach(1..<nRows+1) { i in
                emojiRowView(emojiArr: emojis, nElements: nElementsPerRow, rowNum: i)
            }

        }
        .font(.largeTitle)
    }
    
    /**
     Returns a view containing a row of emojis. This function assumes the provided emoji array and number of elements is divisible with no remainder (mod = 0).
     
     - Parameters:
        - emojiArr: An array of emoji strings
        - nElements: The number of elements in the row
        - rowNum: The row number that is being built
     
     - Returns: A single row in an EmojiView of a single emoji row.
     */
    func emojiRowView(emojiArr: [String], nElements: Int, rowNum: Int) -> some View {
        HStack {
            ForEach((rowNum-1)*nElements..<rowNum*nElements) { i in
                Text(emojiArr[i])
                    .padding(10)
                    .ifTrue(emojiSelection == i) {
                        $0.overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.accentColor, lineWidth: 5)
                        )
                    }
                    .onTapGesture {
                        self.emojiSelection = i
                        self.data.emoji = emojis[i]
                    }
                if i < rowNum*nElements-1 {
                    Spacer()
                }
            }
        }
        .padding(5)
    }
    
}

struct EmojiView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            Section(header: Text("Emoji")) {
                EmojiView()
                    .environmentObject(GiftExchangeFormData())
            }
        }
    }
}
