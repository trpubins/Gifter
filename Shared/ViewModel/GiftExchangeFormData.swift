//
//  GiftExchangeFormData.swift
//  Shared (ViewModel)
//  https://newcombe.io/2020/06/08/validation-with-swiftui-combine-part-2/
//
//  Created by Tanner on 8/8/21.
//

import Foundation
import Combine


/// Holds data associated with a GiftExchange and validation publishers used in a form.
class GiftExchangeFormData: ObservableObject {
    
    
    // MARK: Properties
    
    /// The unique id for the gift exchange
    let id: UUID
    
    /// The name of the gift exchange (a published property)
    @Published var name: String
    
    /// The date of the gift exchange (a published property)
    @Published var date: Date
    
    /// The emoji to identify the gift exchange (a publihsed property)
    @Published var emoji: String
    
    
    // MARK: Initializer
    
    /**
     Initializes the gift exchange data. Published properties are empty by default, and the date is today by default.
     
     - Parameters:
        - name: The name of the gift exchange
        - emoji: The emoji icon of the gift exchange
        - date: The date of the gift exchange
        - christmasDay: `true` to default the form calendar to Christmas day
     */
    init(name: String = "", emoji: String = emojis.first!, date: Date = Date(), christmasDay: Bool = false) {
        self.id = UUID()
        self.name = name
        
        if christmasDay {
            // override emoji to be Christmas tree if making it a Christmas day exchange
            self.emoji = "🎄"
            
            // default the form date to Christmas day of the current year
            let today = Date.today
            var currentYear = Calendar.current.component(.year,  from: today)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            let christmasDate = formatter.date(from: "\(currentYear)/12/25")!
            
            // move to next year if Christmas day of the current year has already passed
            if today > christmasDate.noon {
                currentYear += 1
            }
            
            self.date = formatter.date(from: "\(currentYear)/12/25")!
        } else {
            self.emoji = emoji
            self.date = date
        }
        
        // ensure the date is normalized to noon time so date validation has same reference point
        self.date = self.date.noon
    }
    
    /**
     Initializes the gift exchange data using a GiftExchange object.
     
     - Parameters:
        - giftExchange: The GiftExchange to replicate as form data
     */
    init(giftExchange: GiftExchange) {
        self.id = giftExchange.id
        self.name = giftExchange.name
        self.emoji = giftExchange.emoji
        // ensure the date is normalized to noon time so date validation has same reference point
        self.date = giftExchange.date.noon
    }
    
    
    // MARK: Object Methods
    
    /**
     Determines if the form data has changed compared to the properties of the specified gift exchange.
     
     - Parameters:
        - giftExchange: The gift exchange whose properties to compare
     
     - Returns: `true` if the form data differs from any property values, `false` otherwise.
     */
    func hasChanged(comparedTo giftExchange: GiftExchange) -> Bool {
        return (
            self.name != giftExchange.name
            || self.date.noon != giftExchange.date.noon
            || self.emoji != giftExchange.emoji
        )
    }
    
    
    // MARK: Validation Publishers
    
    /**
     Validates that the name property is not empty.
     
     - Parameters:
        - dropFirst: `true` to drop the first element that is published, `false` to drop no elements. By default, this parameter is `false`.
     
     - Returns: A validation publisher for the name property ensuring it is not empty.
     */
    func nameValidation(dropFirst: Bool = false) -> ValidationPublisher {
        return $name.nonEmptyValidator("Name must be provided", dropFirst: dropFirst)
    }
    
    /// Validates that the date property is after yesterday's date
    lazy var dateValidation: ValidationPublisher = {
        $date.dateValidation(afterDate: Date.yesterday, errorMessage: "Date must be after yesterday")
    }()
    
    /// Detects a change to the emoji property and always returns valid
    lazy var emojiValidation: ValidationPublisher = {
        $emoji.alwaysValid()
    }()

    
    // MARK: Combined Publishers
    
    /// Validates that all the ValidationPublishers are successful
    lazy var allValidation: ValidationPublisher = {
        Publishers.CombineLatest3(
            nameValidation(),
            dateValidation,
            emojiValidation
        ).map { v1, v2, v3 in
            return [v1, v2, v3].allSatisfy { $0.isSuccess } ? .success : .failure(message: "")
        }.eraseToAnyPublisher()
    }()

}

