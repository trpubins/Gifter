//
//  GiftExchangeFormData.swift
//  Shared (Model)
//
//  Created by Tanner on 8/8/21.
//

import Foundation
import Combine

class GiftExchangeFormData: ObservableObject {
    
    
    // MARK: Published Properties
    
    /// The name of the gift exchange (a published property)
    @Published var name: String
    
    /// The date of the gift exchange (a published property)
    @Published var date: Date
    
    /// The unique id for the gift exchange
    let id: UUID
    
    
    // MARK: Initializer
    
    /**
     Initializes the gift exchange data. Published properties are empty by default, and the date is today by default.
     
     - Parameters:
        - id: The unique id for the gift exchange
        - name: The name of the gift exchange
        - date: The date of the gift exchange
        - defaultToXmasDay: `true` to default the form calendar to Christmas day
     */
    init(id: UUID = UUID(), name: String = "", date: Date? = nil, defaultToXmasDay: Bool = false) {
        self.id = id
        self.name = name
        
        if defaultToXmasDay {
            // defaults the form date to Christmas day of the current year
            let currentYear = Calendar.current.component(.year,  from: Date())
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            self.date = formatter.date(from: "\(currentYear)/12/25")!
            return
        }
        
        // update with provided date, or today's date
        if date != nil {
            self.date = date!
        } else {
            self.date = Date()
        }
    }
    
    
    // MARK: Validation Publishers
    
    /// Validates that the name property is not empty
    lazy var nameValidation: ValidationPublisher = {
        $name.nonEmptyValidator("Name must be provided")
    }()
    
    /// Validates that the date property is after yesterday
    lazy var dateValidation: ValidationPublisher = {
        $date.dateValidation(afterDate: Date.yesterday, errorMessage: "Date must be after yesterday")
    }()

    
    // MARK: Combined Publishers
    
    /// Validates that all the ValidationPublishers are successful
    lazy var allValidation: ValidationPublisher = {
        Publishers.CombineLatest(
            nameValidation,
            dateValidation
        ).map { v1, v2 in
            return [v1, v2].allSatisfy { $0.isSuccess } ? .success : .failure(message: "")
        }.eraseToAnyPublisher()
    }()

}

