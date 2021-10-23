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
            if selectedGiftExchange.gifters.count == 0 {
                Text("There are no gifters participating in this gift exchange!")
                    .multilineTextAlignment(.center)
                if #available(iOS 15.0, *) {
                    Button(action: { addGifter() }) {
                        Label("Add Gifter", systemImage: "plus")
                    }
                    .tint(.accentColor)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .padding()
                } else {
                    // fallback on earlier versions
                    Button(action: { addGifter() }) {
                        Label("Add Gifter", systemImage: "plus")
                    }
                    .padding()
                }
            } else {
                List(selectedGiftExchange.gifters) { gifter in
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
                }
            }
            
            Spacer()
        }  // end VStack
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { logAppear(title: "GiftersTabView") }
    }
    
    /// Triggers a sheet for adding a new gifter and changes the tab selection to the Gifters Tab.
    func addGifter() {
        logFilter("add gifter")
        triggers.isAddGifterFormShowing = true
    }
    
}

struct GiftersTabView_Previews: PreviewProvider {
    
    static let previewGiftExchange1: GiftExchange = GiftExchange(context: PersistenceController.shared.context)
    static var previewGiftExchange2: GiftExchange? = nil

    struct GiftersTabView_Preview: View {
        let previewGifters = getPreviewGifters()
        
        init() {
            GiftersTabView_Previews.previewGiftExchange2 = GiftExchange(context: PersistenceController.shared.context)
            
            for gifter in previewGifters {
                GiftersTabView_Previews.previewGiftExchange2!.addGifter(gifter)
            }
        }
        
        var body: some View {
            GiftersTabView()
        }
    }
    
    static var previews: some View {
        // 1st preview
        GiftersTabView()
            .environmentObject(previewGiftExchange1)
        // 2nd preview
        NavigationView {
            GiftersTabView_Preview()
                .environmentObject(previewGiftExchange2!)
        }
    }
    
}
