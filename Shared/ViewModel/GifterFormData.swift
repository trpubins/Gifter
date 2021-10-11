//
//  GifterFormData.swift
//  Shared (ViewModel)
//  https://newcombe.io/2020/06/08/validation-with-swiftui-combine-part-2/
//
//  Created by Tanner on 8/29/21.
//

import Foundation
import Combine
import SwiftUI


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
    @Published var wishLists: [WishList] = []

    
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
        self.wishLists = genWishLists(from: wishLists)
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
        self.wishLists = genWishLists(from: gifter.wishLists)
    }
    
    /**
     Initializes the gifter data using a different GifterFormData object.
     
     - Parameters:
        - formData: The data used to establish the form data
     */
    init(formData: GifterFormData) {
        self.id = formData.id
        self.name = formData.name
        self.email = formData.email
        self.restrictedIds = formData.restrictedIds
        self.wishLists = formData.wishLists
    }
    
    
    // MARK: Object Methods
    
    /**
     Resets the gifter data using a different GifterFormData object.
     
     - Parameters:
        - formData: The data used to reset this gifter form data
     */
    func resetForm(with formData: GifterFormData) {
        self.name = formData.name
        self.email = formData.email
        self.restrictedIds = formData.restrictedIds
        self.wishLists = formData.wishLists
    }
    
    /// Adds a wish list to the gifter.
    func addWishList() {
        wishLists.append(WishList())
        logFilter("add wish list")
    }
    
    /**
     Deletes a wish list from the gifter.
     
     Since WishList is a struct, need to pass in a binding to the wish list so that the parameter is not simply passed by value.
     
     - Parameters:
        - wishList: A binding to the wish list to be deleted
     */
    func deleteWishList(_ wishList: Binding<WishList>) {
        // need to update the wish list url before deleting the wish list to guarantee that the
        // wishLists property publishes itself for validation
        wishList.wrappedValue.url = ""
        
        // there will only be one wish list removed since equatability uses the wish list unique id
        wishLists.removeAll(where: { $0 == wishList.wrappedValue })
        logFilter("delete wish list")
    }
    
    /**
     Converts the array of WishList into an array of wish list urls.
     
     - Returns: An array of url addresses.
     */
    func getWishListURLs() -> [String] {
        var urlArray: [String] = []
        for list in wishLists {
            // do not append any empty urls (represents a blank text field)
            if list.url != "" {
                urlArray.append(list.url)
            }
        }
        return urlArray
    }
    
    /**
     Converts an array of url addresses into an array of WishList.
     
     - Parameters:
        - urls: The url addresses as an array
     */
    func genWishLists(from urls: [String]) -> [WishList] {
        var wishListArray: [WishList] = []
        for url in urls {
            wishListArray.append(WishList(with: url))
        }
        return wishListArray
    }
    
    /**
     Determines if the form data has changed compared to the properties of the specified gifter.
     
     - Parameters:
        - gifter: The gifter whose properties to compare
     
     - Returns: `true` if the form data differs from any property values, `false` otherwise.
     */
    func hasChanged(comparedTo gifter: Gifter) -> Bool {
        return (
            self.name != gifter.name
            || self.email != gifter.email
            || !self.restrictedIds.elementsEqual(gifter.restrictedIds)
            || !self.getWishListURLs().elementsEqual(gifter.wishLists)
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
    
    /**
     Validates that the email property matches the email regular expression.
     
     - Parameters:
        - dropFirst: `true` to drop the first element that is published, `false` to drop no elements. By default, this parameter is `false`.
     
     - Returns: A validation publisher for the email property ensuring it matches the email regular expression.
     */
    func emailValidation(dropFirst: Bool = false) -> ValidationPublisher {
        return $email.matcherValidation(CommonRegex.email,
                                        "Must be a valid email address.",
                                        dropFirst: dropFirst)
    }
    
    /// Detects a change to the restricted ids property and always returns valid
    lazy var restrictionsValidation: ValidationPublisher = {
        $restrictedIds.alwaysValid()
    }()
    
    /**
     Validates that the wish list property with the provided id matches the url regular expression.
     
     - Parameters:
        - id: The unique identifier for the wish list
     
     - Returns: A validation publisher for the unique list in the wish list array.
     */
    func wishListValidation(_ id: UUID, dropFirst: Bool = false) -> ValidationPublisher {
        return $wishLists.wishListValidation(id,
                                             CommonRegex.url,
                                             "Must be a valid URL address.",
                                             dropFirst: dropFirst)
    }
    
    /// Validates that all elements in a wish list array match the url address regular expression
    lazy var allWishListValidation: ValidationPublisher = {
        $wishLists.allWishListValidation(CommonRegex.url,
                                         "Must be a valid URL address.",
                                         dropFirst: false)
    }()
    
    
    // MARK: Combined Publishers
    
    /// Validates that all the ValidationPublishers are successful
    lazy var allValidation: ValidationPublisher = {
        Publishers.CombineLatest4(
            nameValidation(),
            emailValidation(),
            restrictionsValidation,
            allWishListValidation
        ).map { v1, v2, v3, v4 in
            return [v1, v2, v3, v4].allSatisfy { $0.isSuccess } ? .success : .failure(message: "")
        }.eraseToAnyPublisher()
    }()
    
}

