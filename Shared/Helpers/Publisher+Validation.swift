//
//  Publisher+Validation.swift
//  Shared (Helper)
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
    
    /**
     Validates whether a string property is non-empty.
     
     - Parameters:
        - errorMessage: The message to provide in an invalid scenario
        - dropFirst: `true` drops the first element from the publisher, `false` does not drop any elements
     
     - Returns: The validation publisher that validates against non-empty strings.
     */
    func nonEmptyValidator(_ errorMessage: @autoclosure @escaping ValidationErrorClosure,
                           dropFirst: Bool) -> ValidationPublisher {
        return ValidationPublishers.nonEmptyValidation(for: self,
                                                       errorMessage: errorMessage(),
                                                       dropFirst: dropFirst)
    }
    
    /**
     Validates whether a string matches a regular expression.
     
     - Parameters:
        - pattern: The regular expression pattern to match
        - errorMessage: The message to provide in an invalid scenario
        - dropFirst: `true` drops the first element from the publisher, `false` does not drop any elements
     
     - Returns: The validation publisher that validates against a regular expression.
     */
    func matcherValidation(_ pattern: String,
                           _ errorMessage: @autoclosure @escaping ValidationErrorClosure,
                           dropFirst: Bool) -> ValidationPublisher {
        return ValidationPublishers.matcherValidation(for: self,
                                                      withPattern: pattern.r!,
                                                      errorMessage: errorMessage(),
                                                      dropFirst: dropFirst)
    }
    
    /**
     Retrieves a publisher that will always publish valid.

     - Returns: The validation publisher that always emits .success.
     */
    func alwaysValid() -> ValidationPublisher {
        return ValidationPublishers.alwaysValid(for: self)
    }
    
}

extension Published.Publisher where Value == [UUID] {

    /**
     Retrieves a publisher that will always publish valid.
     
     - Returns: The validation publisher that always emits .success.
     */
    func alwaysValid() -> ValidationPublisher {
        return ValidationPublishers.alwaysValid(for: self)
    }
    
}


extension Published.Publisher where Value == [WishList] {
    
    /**
     Validates whether an array element in a wish list matches the provided regular expression.
     
     - Parameters:
        - id: The id of the wish list used in filtering the wish list array
        - pattern: The regular expression pattern to match
        - errorMessage: The message to provide in an invalid scenario
        - dropFirst: `true` drops the first element from the publisher, `false` does not drop any elements
     
     - Returns: The validation publisher that validates against the regular expression.
     */
    func wishListValidation(_ id: UUID,
                            _ pattern: String,
                            _ errorMessage: @autoclosure @escaping ValidationErrorClosure,
                            dropFirst: Bool) -> ValidationPublisher {
        return ValidationPublishers.wishListValidation(for: self,
                                                       withId: id,
                                                       withPattern: pattern.r!,
                                                       errorMessage: errorMessage(),
                                                       dropFirst: dropFirst)
    }
    
    /**
     Validates whether all array elements in a wish list match the provided regular expression.
     
     - Parameters:
        - pattern: The regular expression pattern to match
        - errorMessage: The message to provide in an invalid scenario
        - dropFirst: `true` drops the first element from the publisher, `false` does not drop any elements
     
     - Returns: The validation publisher that validates all array elements against the regular expression.
     */
    func allWishListValidation(_ pattern: String,
                               _ errorMessage: @autoclosure @escaping ValidationErrorClosure,
                               dropFirst: Bool) -> ValidationPublisher {
        return ValidationPublishers.allWishListValidation(for: self,
                                                          withPattern: pattern.r!,
                                                          errorMessage: errorMessage(),
                                                          dropFirst: dropFirst)
    }
    
}

extension Published.Publisher where Value == Date {
     
    /**
     Validates whether a date falls between a date range. If one of the bounds isn't provided, a suitable distant detail is used.
     
     - Parameters:
        - after: Optionally provide this date  - serves as the date validation lower bound
        - before: Optionally provide this date  - serves as the date validation upper bound
        - errorMessage: The message to provide in an invalid scenario
     
     - Returns: The validation publisher that validates against a date range.
     */
    func dateValidation(afterDate after: Date = .distantPast,
                         beforeDate before: Date = .distantFuture,
                         errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        return ValidationPublishers.dateValidation(for: self,
                                                   afterDate: after,
                                                   beforeDate: before,
                                                   errorMessage: errorMessage())
    }
}
