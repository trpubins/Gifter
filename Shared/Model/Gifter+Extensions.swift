//
//  Gifter+Extensions.swift
//  Shared (Model)
//
//  Created by Tanner on 8/6/21.
//

import Foundation
import CoreData
import UIKit

/// A person who spreads good giving vibes.
extension Gifter {
    
    
    // MARK: Property Wrappers
    
    /// The id that uniquely identifies the gifter
    public var id: UUID {
        get { id_ ?? UUID() }
    }
    
    /// The name of the gifter
    public var name: String {
        get { name_ ?? "Unknown gifter name" }
        set { name_ = newValue }
    }
    
    /// The gifter's email address
    public var email: Email {
        get { email_ ?? Email(address: "Unknown email") }
        set { email_ = newValue }
    }
    
    /// The gifter's profile picture
    public var profilePic: UIImage? {
        get {
            if let pic = profilePic_ {
                return UIImage(data: pic)
            } else {
                return nil
            }
        }
        set { profilePic_ = newValue?.jpegData(compressionQuality: 1.0) }
    }
    
    /// The id of a gifter who previously received gifts from this gifter
    public var previousRecipientId: UUID? {
        get { previousRecipientId_ }
        set { previousRecipientId_ = newValue }
    }
    
    /// The id of a gifter who shall receive gifts from this gifter
    public var recipientId: UUID? {
        get { recipientId_ }
        set { recipientId_ = newValue }
    }
    
    /// An array of restricted gifter ids
    public var restrictedIds: [UUID] {
        get { restrictedIds_ ?? [] }
        set { restrictedIds_ = newValue }
    }
    
    /// An array of wish list URLs
    public var wishLists: [String] {
        get { wishLists_ ?? [] }
        set { wishLists_ = newValue }
    }
    
    /// An array of unique identifiers, each of which identify a gift exchange that this gifter is participating in
    public var exchangeIds: [UUID] {
        get { exchangeIds_ ?? [] }
        set { exchangeIds_ = newValue }
    }
    
    /// This gifter's associated gift exchanges -- converts NSSet to swift array
    public var giftExchanges: [GiftExchange] {
        get {
            let set = giftExchanges_ as? Set<GiftExchange> ?? []
            return set.sorted()  // GiftExchange conforms to comparable so set can be sorted here
        }
    }
    
    
    // MARK: Object Methods
    
    /**
     Initializes the unique id for this Gifter from the provided id.
     
     - Parameters:
        - id: The gifter unique id
     */
    private func initId(withId id: UUID) {
        id_ = id
    }
    
    /**
     Initializes an empty email for this Gifter.
     */
    private func initEmail() {
        email_ = Email()
    }
    
    /**
     Updates the values of this Gifter's instance members.
     
     - Parameters:
        - data: The gifter form data
     */
    private func updateValues(from data: GifterFormData) {
        self.name = data.name
        self.email.address = data.email
        self.restrictedIds = data.restrictedIds
        self.wishLists = data.getWishListURLs()
    }
    
    /// Resets the email state back to the default state.
    public func resetEmailState() {
        let address = self.email.address
        self.email = Email(address: address, state: .Unsent)
    }
    
    /// Advances the email state to the next state.
    public func advanceEmailState() {
        let address = self.email.address
        self.email = Email(address: address, state: .Sent)
    }
    
    /**
     Adds an id to the Gifter's restricted list. This means the Gifter will not gift an individual with that id.
     
     - Parameters:
        - id: The id to add to the restricted list
     
     - Returns: `true` if the id was successfully added; `false ` if the id already exists.
     */
    @discardableResult
    public func addRestrictedId(_ id: UUID) -> Bool {
        if self.restrictedIds.contains(id) {
            return false
        }
        restrictedIds_?.append(id)
        return true
    }
    
    /**
     Removes an id from the Gifter's restricted list. Following this action, the Gifter will be able to gift an individual with the specified id.

     - Parameters:
        - id: The id to remove from the restricted list

     - Returns: `true` if the id was successfully removed; `false ` if the id does not exist.
     */
    @discardableResult
    public func removeRestrictedId(_ id: UUID) -> Bool {
        if !self.restrictedIds.contains(id) {
            return false
        }
        restrictedIds_ = self.restrictedIds.filter {$0 != id}  // removes the array element by value
        return true
    }
    
    /**
     Adds a new list so the gifter's wishes might come true.
     
     - Parameters:
        - list: The new wish list to add
     
     - Returns: `true` if the wish list was successfully added; `false ` if the wish list already exists.
     */
    @discardableResult
    public func addWishList(_ list: String) -> Bool {
        if self.wishLists.contains(list) {
            return false
        }
        wishLists_?.append(list)
        return true
    }
    
    /**
     Removes a wish list from the gifter.
     
     - Parameters:
        - list: The wish list to remove
     
     - Returns: `true` if the wish list was successfully removed; `false ` if the wish list does not exist.
     */
    @discardableResult
    public func removeWishList(_ list: String) -> Bool {
        if !self.wishLists.contains(list) {
            return false
        }
        wishLists_ = self.wishLists.filter {$0 != list}  // removes the array element by value
        return true
    }
    
    /**
     Associates a new GiftExchange with the gifter. Additionally, adds the exchange id.
     
     - Parameters:
        - exchange: The new GiftExchange to add
     
     - Returns: `true` if the gift exchange was successfully added; `false ` if the gift exchange already exists.
     */
    @discardableResult
    public func addGiftExchange(_ exchange: GiftExchange) -> Bool {
        if self.giftExchanges.contains(exchange) {
            return false
        }
        self.addObject(value: exchange, forKey: "giftExchanges_")
        self.addExchangeId(exchange.id)
        return true
    }
    
    /**
     Removes the specified GiftExchange from the gifter. Additionally, removes the exchange id.
     
     - Parameters:
        - exchange: The GiftExchange to be removed
     
     - Returns: `true` if the gift exchange was successfully removed; `false ` if the gift exchange does not exist..
     */
    @discardableResult
    public func removeGiftExchange(_ exchange: GiftExchange) -> Bool {
        if !self.giftExchanges.contains(exchange) {
            return false
        }
        self.removeObject(value: exchange, forKey: "giftExchanges_")
        self.removeExchangeId(exchange.id)
        return true
    }
    
    /**
     Associates a new exchange id with the gifter.
     
     - Parameters:
        - id: The new exchange id to add
     
     - Returns: `true` if the exchange id was successfully added; `false ` if the exchange id already exists.
     */
    @discardableResult
    private func addExchangeId(_ id: UUID) -> Bool {
        if self.exchangeIds.contains(id) {
            return false
        }
        exchangeIds_?.append(id)
        return true
    }
    
    /**
     Removes an exchange id from the gifter.
     
     - Parameters:
        - id: The exchange id to remove
     
     - Returns: `true` if the exchange id was successfully removed; `false ` if the exchange id does not exist.
     */
    @discardableResult
    private func removeExchangeId(_ id: UUID) -> Bool {
        if !self.exchangeIds.contains(id) {
            return false
        }
        exchangeIds_ = exchangeIds.filter {$0 != id}  // removes the array element by value
        return true
    }
    
    /**
     Combines different elements of a gifter into a single string.
     
     - Returns: A combined string with the gifter's descriptive components.
     */
    public func toString() -> String {
        return "\(self.name), \(self.email.address)"
    }
    
    
    // MARK: Class Functions
    
    /**
     Attempts to retrieve a gifter with the specified id.
     
     - Parameters:
        - id: The id used to identify the gifter
     
     - Returns: The identified gifter or `nil` if the identified gifter was not found.
     */
    class func get(withId id: UUID) -> Gifter? {
        return Gifter.object(withId: id, context: PersistenceController.shared.context)
    }
    
    /**
     Initializes a new gifter with default values.
     
     - Returns: A new gifter.
     */
    private class func add() -> Gifter {
        let newGifter = Gifter(context: PersistenceController.shared.context)
        newGifter.initEmail()
        return newGifter
    }
    
    /**
     Initializes a new gifter with the provided form data.
     
     - Parameters:
        - data: The form data used to initialize the gifter
     
     - Returns: A new gifter.
     */
    class func add(using data: GifterFormData) -> Gifter {
        let newGifter = Gifter.add()
        newGifter.initId(withId: data.id)
        newGifter.updateValues(from: data)
        return newGifter
    }
    
    /**
     Updates the gifter with the provided form data.
     
     - Parameters:
        - data: The form data used to update the gifter
     
     - Returns: The updated gifter.
     */
    class func update(using data: GifterFormData) -> Gifter {
        if let gifter = Gifter.object(withId: data.id, context: PersistenceController.shared.context) {
            // if we can find a Gifter object in CoreData, use it
            gifter.updateValues(from: data)
            return gifter
        } else {
            // otherwise, create a new Gifter from the provided data
            return Gifter.add(using: data)
        }
    }
    
    /**
     Deletes the specified gifter from CoreData.
     
     - Parameters:
        - gifter: The gifter to be deleted
     */
    class func delete(gifter: Gifter, selectedGiftExchange: GiftExchange) {
        // first, remove the gifter from the selected gift exchange
        selectedGiftExchange.removeGifter(gifter)
        // now delete and save
        let context = gifter.managedObjectContext
        context?.delete(gifter)
        try? context?.save()
    }
    
}

extension Gifter: Comparable {
    
    
    // MARK: - Conform to Comparable
    
    // equatability is based on the Gifter's unique id
    public static func == (lhs: Gifter, rhs: Gifter) -> Bool {
        return lhs.id == rhs.id
    }
    
    // order is based on a Gifter's name
    public static func < (lhs: Gifter, rhs: Gifter) -> Bool {
        return lhs.name < rhs.name
    }
    
}

