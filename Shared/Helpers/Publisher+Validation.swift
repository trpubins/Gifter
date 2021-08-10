//
//  Publisher+Validation.swift
//  SwiftUI-Validation (Helper)
//  https://newcombe.io/2020/03/05/validation-with-swiftui-combine-part-1/
//  https://github.com/jnewc/SwiftUI-Validation
//  Apache-2.0 License
//
//  Created by Jack Newcombe on 01/03/2020.
//  Copyright © 2020 Jack Newcombe. All rights reserved.
//

import Foundation
import Combine
import Regex

extension Published.Publisher where Value == String {
    
    func nonEmptyValidator(_ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        return ValidationPublishers.nonEmptyValidation(for: self, errorMessage: errorMessage())
    }
    
    func matcherValidation(_ pattern: String, _ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        return ValidationPublishers.matcherValidation(for: self, withPattern: pattern.r!, errorMessage: errorMessage())
    }
    
}

extension Published.Publisher where Value == Date {
     func dateValidation(afterDate after: Date = .distantPast,
                         beforeDate before: Date = .distantFuture,
                         errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        return ValidationPublishers.dateValidation(for: self, afterDate: after, beforeDate: before, errorMessage: errorMessage())
    }
}
