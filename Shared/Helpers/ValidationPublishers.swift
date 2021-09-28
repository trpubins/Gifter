//
//  ValidationPublishers.swift
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

typealias ValidationErrorClosure = () -> String

typealias ValidationPublisher = AnyPublisher<Validation, Never>

/// Stores several functions for providing publishers that perform validation on user input.
class ValidationPublishers {

    /**
     Validates whether a string property is non-empty.
     
     - Parameters:
        - publisher: The class property that is publishing values
        - errorMessage: The message to provide in an invalid scenario
        - dropFirst: `true` drops the first element from the publisher, `false` does not drop any elements
     
     - Returns: The validation publisher that validates against non-empty strings.
     */
    static func nonEmptyValidation(for publisher: Published<String>.Publisher,
                                   errorMessage: @autoclosure @escaping ValidationErrorClosure,
                                   dropFirst: Bool) -> ValidationPublisher {
        
        func getPublisherMap() -> Publishers.Map<Published<String>.Publisher, Validation> {
            return publisher.map { value in
                guard value.count > 0 else {
                    return .failure(message: errorMessage())
                }
                return .success
            }
        }
        
        return getValidationPublisher(getPublisherMap(), dropFirst: dropFirst)
    }
    
    /**
     Validates whether a string matches a regular expression.
     
     - Parameters:
        - publisher: The class property that is publishing values
        - pattern: The regular expression pattern to match
        - errorMessage: The message to provide in an invalid scenario
        - dropFirst: `true` drops the first element from the publisher, `false` does not drop any elements
     
     - Returns: The validation publisher that validates against a regular expression.
     */
    static func matcherValidation(for publisher: Published<String>.Publisher,
                                  withPattern pattern: Regex,
                                  errorMessage: @autoclosure @escaping ValidationErrorClosure,
                                  dropFirst: Bool) -> ValidationPublisher {
        
        func getPublisherMap() -> Publishers.Map<Published<String>.Publisher, Validation> {
            return publisher.map { value in
                guard pattern.matches(value) else {
                    return .failure(message: errorMessage())
                }
                return .success
            }
        }
        
        return getValidationPublisher(getPublisherMap(), dropFirst: dropFirst)
    }
    
    /**
     Retrieves a publisher that will always publish valid.
     
     - Parameters:
        - publisher: The class property that is publishing values
     
     - Returns: The validation publisher that always emits .success.
     */
    static func alwaysValid(for publisher: Published<String>.Publisher) -> ValidationPublisher {
        
        func getPublisherMap() -> Publishers.Map<Published<String>.Publisher, Validation> {
            return publisher.map { value in
                return .success
            }
        }

        return getValidationPublisher(getPublisherMap(), dropFirst: false)
    }
    
    /**
     Validates whether an array element in a wish list matches the provided regular expression.
     
     - Parameters:
        - publisher: The class property that is publishing values
        - id: The id of the wish list used in filtering the wish list array
        - pattern: The regular expression pattern to match
        - errorMessage: The message to provide in an invalid scenario
        - dropFirst: `true` drops the first element from the publisher, `false` does not drop any elements
     
     - Returns: The validation publisher that validates against the regular expression.
     */
    static func wishListValidation(for publisher: Published<Array<WishList>>.Publisher,
                                   withId id: UUID,
                                   withPattern pattern: Regex,
                                   errorMessage: @autoclosure @escaping ValidationErrorClosure,
                                   dropFirst: Bool) -> ValidationPublisher {
        
        func getPublisherMap() -> Publishers.Map<Published<Array<WishList>>.Publisher, Validation> {
            return publisher.map { array in
                if let value = array.first(where: { $0.id == id }) {
                    guard pattern.matches(value.url) else {
                        return .failure(message: errorMessage())
                    }
                    return .success
                } else {
                    return .success
                }
            }
        }
        
        return getValidationPublisher(getPublisherMap(), dropFirst: dropFirst)
    }
    
    /**
     Validates whether a date falls between a date range. If one of the bounds isn't provided, a suitable distant detail is used.
     
     - Parameters:
        - publisher: The class property that is publishing values
        - after: Optionally provide this date  - serves as the date validation lower bound
        - before: Optionally provide this date  - serves as the date validation upper bound
        - errorMessage: The message to provide in an invalid scenario
     
     - Returns: The validation publisher that validates against a date range.
     */
    static func dateValidation(for publisher: Published<Date>.Publisher,
                               afterDate after: Date = .distantPast,
                               beforeDate before: Date = .distantFuture,
                               errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        
        func getPublisherMap() -> Publishers.Map<Published<Date>.Publisher, Validation> {
            return publisher.map { date in
                return date > after && date < before ? .success : .failure(message: errorMessage())
            }
        }
        
        return getValidationPublisher(getPublisherMap(), dropFirst: false)
    }
    
    /**
     Retrieves the validation publisher and determines if the first element published should be dropped.
     
     - Parameters:
        - publisherMap: Maps a publisher to a validation state
        - dropFirst: `true` drops the first element from the publisher, `false` does not drop any elements
    
     - Returns: The validation publisher with the first element dropped or not.
     */
    private static func getValidationPublisher<T>(_ publisherMap: Publishers.Map<Published<T>.Publisher, Validation>,
                                                  dropFirst: Bool) -> ValidationPublisher {
        // drop the first element published on condition
        if dropFirst {
            return publisherMap
                .dropFirst()
                .eraseToAnyPublisher()
        } else {
            return publisherMap
                .eraseToAnyPublisher()
        }
    }

}
