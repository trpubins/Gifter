//
//  GifterFormData.swift
//  Shared (Model)
//  https://newcombe.io/2020/06/08/validation-with-swiftui-combine-part-2/
//
//  Created by Tanner on 8/29/21.
//

import Foundation
import Combine


/// Holds data associated with a Gifter and validation publishers used in a form.
class GifterFormData: ObservableObject {
    
    
    // MARK: Properties
    
    /// The unique id for the gifter
    let id: UUID
    
    /// The name of the gifter (a published property)
    @Published var name: String
    
    /// The email for the gifter (a published property)
    @Published var email: String
    
    /// An array of restricted gifter ids (a publihsed property)
    @Published var restrictedIds: [UUID]
    
    /// An array of wish list URLs (a publihsed property)
    @Published var wishLists: [String]

    
    // MARK: Initializer
    
    /**
     Initializes the gifter data. Published properties are empty by default.
     
     - Parameters:
        - name: The name of the gifter
        - email: The email for the gifter
        - restrictedIds: An array of restricted gifter ids
        - wishLists: An array of wish list URLs
     */
    init(name: String = "", email: String = "", restrictedIds: [UUID] = [], wishLists: [String] = []) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.restrictedIds = restrictedIds
        self.wishLists = wishLists
    }
    
    /**
     Initializes the gifter data using a Gifter object.
     
     - Parameters:
        - gifter: The Gifter to replicate as form data
     */
    init(gifter: Gifter) {
        self.id = gifter.id
        self.name = gifter.name
        self.email = gifter.email
        self.restrictedIds = gifter.restrictedIds
        self.wishLists = gifter.wishLists
    }
    
    
    // MARK: Validation Publishers
    
    /// Validates that the name property is not empty
    lazy var nameValidation: ValidationPublisher = {
        $name.nonEmptyValidator("Name must be provided")
    }()
    
    /// Validates that the email property is not empty
    lazy var emailValidation: ValidationPublisher = {
        $email.nonEmptyValidator("Email must be provided")
    }()
    
    
    // MARK: Combined Publishers
    
    /// Validates that all the ValidationPublishers are successful
    lazy var allValidation: ValidationPublisher = {
        Publishers.CombineLatest(
            nameValidation,
            emailValidation
        ).map { v1, v2 in
            return [v1, v2].allSatisfy { $0.isSuccess } ? .success : .failure(message: "")
        }.eraseToAnyPublisher()
    }()
    
}

