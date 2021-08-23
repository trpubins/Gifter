//
//  Gifter+Extensions.swift
//  Shared (Model)
//
//  Created by Tanner on 8/6/21.
//

import Foundation
import CoreData

/// A person who spreads good giving vibes.
extension Gifter {
    
    
    // MARK: Property Wrappers
    
    /// The id that uniquely identifies the gifter
    public var id: UUID {
        get { id_ ?? UUID() }
    }
    
    /// The gifter's email address
    public var email: String {
        get { email_ ?? "Unknown email" }
        set { email_ = newValue }
    }
    
    /// The name of the gifter
    public var name: String {
        get { name_ ?? "Unknown gifter name" }
        set { name_ = newValue }
    }
    
    /// The email of a person who shall receive gifts from this gifter
    public var recipientEmail: String {
        get { recipientEmail_ ?? "Unknown recipient email" }
        set { recipientEmail_ = newValue }
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
    
    // MARK: - Object Methods
    
    /**
     Adds an id to the Gifter's restricted list. This means the Gifter will not gift an individual with that id.
     
     - Parameters:
        - id: The id to add to the restricted list
     
     - Returns: `true` if the id was successfully added; `false ` if the id already exists.
     */
    public func addRestrictedId(id: UUID) -> Bool {
        if restrictedIds.contains(id) {
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
    public func removeRestrictedId(id: UUID) -> Bool {
        if !restrictedIds.contains(id) {
            return false
        }
        restrictedIds_ = restrictedIds.filter {$0 != id}  // removes the array element by value
        return true
    }
    
    /**
     Adds a new list so the gifter's wishes might come true.
     
     - Parameters:
        - list: The new wish list to add
     
     - Returns: `true` if the wish list was successfully added; `false ` if the wish list already exists.
     */
    public func addWishList(list: String) -> Bool {
        if wishLists.contains(list) {
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
    public func removeWishList(list: String) -> Bool {
        if !wishLists.contains(list) {
            return false
        }
        wishLists_ = wishLists.filter {$0 != list}  // removes the array element by value
        return true
    }
    
    /**
     Associates a new exchange id with the gifter.
     
     - Parameters:
        - id: The new exchange id to add
     
     - Returns: `true` if the exchange id was successfully added; `false ` if the exchange id already exists.
     */
    @discardableResult
    public func addExchangeId(id: UUID) -> Bool {
        if exchangeIds.contains(id) {
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
    public func removeExchangeId(id: UUID) -> Bool {
        if !exchangeIds.contains(id) {
            return false
        }
        exchangeIds_ = exchangeIds.filter {$0 != id}  // removes the array element by value
        return true
    }
    
    /**
     Associates a new GiftExchange with the gifter. Additionally, adds the exchange id.
     
     - Parameters:
        - exchange: The new GiftExchange to add
     
     - Returns: `true` if the gift exchange was successfully added; `false ` if the gift exchange already exists.
     */
    public func addGiftExchange(exchange: GiftExchange) -> Bool {
        if giftExchanges.contains(exchange) {
            return false
        }
        self.addObject(value: exchange, forKey: "giftExchanges_")
        addExchangeId(id: exchange.id)
        return true
    }
    
    /**
     Removes the specified GiftExchange from the gifter. Additionally, removes the exchange id.
     
     - Parameters:
        - exchange: The GiftExchange to be removed
     
     - Returns: `true` if the gift exchange was successfully removed; `false ` if the gift exchange does not exist..
     */
    public func removeGiftExchange(exchange: GiftExchange) -> Bool {
        if !giftExchanges.contains(exchange) {
            return false
        }
        self.removeObject(value: exchange, forKey: "giftExchanges_")
        removeExchangeId(id: exchange.id)
        return true
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

