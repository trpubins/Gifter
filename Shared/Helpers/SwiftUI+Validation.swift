//
//  SwiftUI+Validation.swift
//  SwiftUI-Validation (Helper)
//  https://newcombe.io/2020/03/05/validation-with-swiftui-combine-part-1/
//  https://github.com/jnewc/SwiftUI-Validation
//  Apache-2.0 License
//
//  Created by Jack Newcombe on 02/03/2020.
//  Copyright © 2020 Jack Newcombe. All rights reserved.
//

import Foundation
import SwiftUI

struct ValidationModifier: ViewModifier {
    
    @State var latestValidation: Validation = .success
    
    let validationPublisher: ValidationPublisher
        
    func body(content: Content) -> some View {
        return VStack(alignment: .leading) {
            content
            validationMessage
        }.onReceive(validationPublisher) { validation in
            self.latestValidation = validation
        }
    }
    
    var validationMessage: some View {
        switch latestValidation {
        case .success:
            return AnyView(EmptyView())
        case .failure(let message):
            let text = Text(message)
                .foregroundColor(Color.red)
                .font(.caption)
            return AnyView(text)
        }
    }
}

extension View {
    
    func validation(_ validationPublisher: ValidationPublisher) -> some View {
        self.modifier(ValidationModifier(validationPublisher: validationPublisher))
    }
    
}
