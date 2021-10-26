//
//  GiftersTabView.swift
//  Shared (View)
//
//  Created by Tanner on 8/7/21.
//

import SwiftUI

struct GiftersTabView: View {
    
    /// The gift exchange current selection provided by a parent View
    @EnvironmentObject var selectedGiftExchange: GiftExchange
    
    /// Object encapsulating various state variables provided by a parent View
    @EnvironmentObject var triggers: StateTriggers
    
    
    // MARK: Body
    
    var body: some View {
        
        VStack {
            HStack {
                Text("Gifters")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding([.top, .leading])
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Number of gifters: \(selectedGiftExchange.gifters.count)")
                }
                .padding([.top, .leading, .trailing])
            }  // end HStack
            Spacer()
            // show a list of gifters in the selected gift exchange
            List {
                ForEach(selectedGiftExchange.gifters) { gifter in
                    NavigationLink(
                        destination: GifterFormView(
                            formType: .Edit,
                            data: GifterFormData(gifter: gifter)
                        )
                            .environmentObject(selectedGiftExchange)
                            .environmentObject(gifter)
                    ) {
                        GifterRowView(gifter: gifter)
                    }
                }  // end ForEach
                
                // show an add button at the bottom of the list
                addGifterButton()
            }  // end List
            
            Spacer()
        }  // end VStack
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { logAppear(title: "GiftersTabView") }
    }
    
    
    // MARK: Sub Views
    
    /**
     A button that adds a gifter.
     
     - Returns: A Button View.
     */
    @ViewBuilder
    func addGifterButton() -> some View {
        Button(action: { addGifter() }) {
            HStack {
                Image(systemName: "plus")
                    .resizable()
                    .aspectRatio(nil, contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.Accent)
                    .padding(.horizontal, UIScreen.screenWidth/16)
                Text("Add Gifter").font(.title3)
                    .foregroundColor(Color.Accent)
                Spacer()
            }
        }
    }
    
    
    // MARK: Model Functions
    
    /// Triggers a sheet for adding a new gifter and changes the tab selection to the Gifters Tab.
    func addGifter() {
        logFilter("add gifter")
        triggers.isAddGifterFormShowing = true
    }
    
}

struct GiftersTabView_Previews: PreviewProvider {
    
    static var previewGiftExchange1: GiftExchange? = nil
    static let previewGiftExchange2: GiftExchange = GiftExchange(context: PersistenceController.shared.context)

    struct GiftersTabView_Preview: View {
        let previewGifters = getPreviewGifters()
        
        init() {
            GiftersTabView_Previews.previewGiftExchange1 = GiftExchange(context: PersistenceController.shared.context)
            
            for gifter in previewGifters {
                GiftersTabView_Previews.previewGiftExchange1!.addGifter(gifter)
            }
        }
        
        var body: some View {
            GiftersTabView()
        }
    }
    
    static var previews: some View {
        // 1st preview
        NavigationView {
            GiftersTabView_Preview()
                .environmentObject(previewGiftExchange1!)
        }
        // 2nd preview
        GiftersTabView()
            .environmentObject(previewGiftExchange2)
    }
    
}
