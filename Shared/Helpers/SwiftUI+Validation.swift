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
    
    /// Saves the latest validation scenario to state
    @State var latestValidation: Validation = .empty
    
    /// Publishes the validation scenario
    let validationPublisher: ValidationPublisher
    
    @ViewBuilder
    func body(content: Content) -> some View {
        VStack(alignment: .leading) {
            HStack {
                content
                    .onReceive(validationPublisher) { validation in
                        self.latestValidation = validation
                    }
                Spacer()
                validationCheckmark
            }
            validationMessage
        }
    }
    
    /// Uses the validation state to return a checkmark for valid scenarios
    private var validationCheckmark: some View {
        switch latestValidation {
        case .success:
            return AnyView(Image(systemName: "checkmark.circle.fill"))
        case .failure, .empty:
            return AnyView(EmptyView())
        }
    }
    
    /// Uses the validation state to return an error message for invalid scenarios
    private var validationMessage: some View {
        switch latestValidation {
        case .success, .empty:
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
    
    /**
     Modifies a form sub view depending on the validation scenario.
     
     - Parameters:
        - validationPublisher: Publishes the validation scenario
     
     - Returns: The modified view.
     */
    func validation(_ validationPublisher: ValidationPublisher) -> some View {
        self.modifier(ValidationModifier(validationPublisher: validationPublisher))
    }
    
}
