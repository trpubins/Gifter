//
//  Validation.swift
//  SwiftUI-Validation (Helper)
//  https://newcombe.io/2020/03/05/validation-with-swiftui-combine-part-1/
//  https://github.com/jnewc/SwiftUI-Validation
//  Apache-2.0 License
//
//  Created by Jack Newcombe on 01/03/2020.
//  Copyright © 2020 Jack Newcombe. All rights reserved.
//

import Foundation

enum Validation {
    case success
    case failure(message: String)
    case empty
    
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
}
