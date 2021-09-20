//
//  GifterRowView.swift
//  GifterRowView
//
//  Created by Tanner on 9/18/21.
//

import SwiftUI

struct GifterRowView: View {
    
    var gifter: Gifter
    
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .aspectRatio(nil, contentMode: .fit)
                .frame(width: 30, height: 30)
                .padding(.horizontal, UIScreen.screenWidth/20)
            Text(gifter.name).font(.title2)
            Spacer()
        }
    }
}

struct GifterRowView_Previews: PreviewProvider {
    static let previewGifters: [Gifter] = getPreviewGifters()
    
    static var previews: some View {
        List(previewGifters, id: \.self) { previewGifter in
            GifterRowView(gifter: previewGifter)
        }
    }
}
