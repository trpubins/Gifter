//
//  ExchangeMatchingView.swift
//  Shared (View)
//
//  Created by Tanner on 10/31/21.
//

import SwiftUI

struct ExchangeMatchingView: View {
    
    /// The gift exchange current selection provided by a parent View
    @EnvironmentObject var selectedGiftExchange: GiftExchange
    
    /// The grid column configuration
    let columns = [
        // no horizontal spacing
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    /// The color of the grid border
    let borderColor = Color.secondary
    
    
    // MARK: Body
    
    var body: some View {
        
        let gifters = selectedGiftExchange.gifters
        let screenWidth = UIScreen.screenWidth
        
        // no vertical spacing
        VStack(spacing: 0) {
            
            // no vertical spacing
            LazyVGrid(columns: columns, spacing: 0) {
                // header row
                headerText("Gifter", screenWidth: screenWidth)
                headerText("Recipient", screenWidth: screenWidth)
                headerText("Email Status", screenWidth: screenWidth)
            }  // end LazyVGrid
            
            // the content rows shall be scrollable
            ScrollView {
                // no vertical spacing
                LazyVGrid(columns: columns, spacing: 0) {
                    // content rows
                    ForEach(gifters) { gifter in
                        // ensure the gifter has a recipient first
                        if let recipientId = gifter.recipientId {
                            let recipient = Gifter.get(withId: recipientId)
                            
                            contentText(gifter.name, screenWidth: screenWidth)
                            contentText(recipient?.name ?? "Unknown", screenWidth: screenWidth)
                            contentText(gifter.email.state.rawValue, screenWidth: screenWidth)
                        }
                    }
                }  // end LazyVGrid
            }  // end ScrollView
            
        }  // end VStack
        .padding(.horizontal)
    }
    
    
    // MARK: Sub Views
    
    /**
     Template for the grid view header text.
     
     - Parameters:
        - text: The text to display
        - screenWidth: The width of the screen
     
     - Returns: A grid header Text View.
     */
    @ViewBuilder
    func headerText(_ text: String, screenWidth: CGFloat) -> some View {
        Text(text).font(.title2).fontWeight(.semibold)
            .frame(width: screenWidth/3.25, height: 100)
            .background(Rectangle().strokeBorder(borderColor))
    }
    
    /**
     Template for the grid view content text.
     
     - Parameters:
        - text: The text to display
        - screenWidth: The width of the screen
     
     - Returns: A grid (cell) content Text View.
     */
    @ViewBuilder
    func contentText(_ text: String, screenWidth: CGFloat) -> some View {
        Text(text).font(.title3)
            .padding()
            .frame(width: screenWidth/3.25)
            .background(Rectangle().strokeBorder(borderColor))
    }
    
}

struct ExchangeMatchingView_Previews: PreviewProvider {
    
    static var previewGiftExchange1: GiftExchange? = nil
    
    struct ExchangeMatchingView_Preview: View {
        let previewGifters = getPreviewGifters()
        
        init() {
            ExchangeMatchingView_Previews.previewGiftExchange1 = GiftExchange(context: PersistenceController.shared.context)
            
            for gifter in previewGifters {
                ExchangeMatchingView_Previews.previewGiftExchange1!.addGifter(gifter)
            }
        }
        
        var body: some View {
            ExchangeMatchingView()
        }
    }
    
    static var previews: some View {
        // 1st preview
        ExchangeMatchingView_Preview()
            .environmentObject(previewGiftExchange1!)
    }
}
