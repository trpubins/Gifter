//
//  GiftExchange+Extensions.swift
//  Shared (Model)
//
//  Created by Tanner on 8/6/21.
//

import Foundation
import CoreData

/// A gift exchange, which holds meta data and acts as a container for any number of gifters.
extension GiftExchange {
    
    
    // MARK: Property Wrappers
    
    /// The id that uniquely identifies the gift exchange
    public var id: UUID {
        get { id_ ?? UUID() }
    }
    
    /// The date of the gift exchange 
    public var date: Date {
        get { date_ ?? Date() }
        set { date_ = newValue }
    }
    
    /// The name of the gift exchange
    public var name: String {
        get { name_ ?? "Unknown name" }
        set { name_ = newValue }
    }
    
    /// The emoji to identify the gift exchange
    public var emoji: String {
        get { emoji_ ?? emojis.first! }
        set { emoji_ = newValue }
    }
    
    /// This gift exchange's associated gifters -- converts NSSet to swift array
    public var gifters: [Gifter] {
        get {
            let set = gifters_ as? Set<Gifter> ?? []
            return set.sorted()  // Gifter conforms to comparable so set can be sorted here
        }
    }
    
    
    // MARK: Object Methods
    
    /**
     Initializes the unique id for this GiftExchange from the form data.
     
     - Parameters:
        - data: The gift exchange form data
     */
    private func initId(from data: GiftExchangeFormData) {
        id_ = data.id
    }
    
    /**
     Updates the values of this GiftExchange's instance members.
     
     - Parameters:
        - data: The gift exchange form data
     */
    private func updateValues(from data: GiftExchangeFormData) {
        self.date = data.date
        self.name = data.name
        self.emoji = data.emoji
    }
    
    /**
     Combines different elements of a gift exchange into a single string.
     
     - Returns: A combined string with the gift exchange's descriptive components.
     */
    public func toString() -> String {
        return "\(self.emoji)  \(self.name)  " + String(self.date.year)
    }
    
    
    // MARK: Class Functions
    
    /**
     Retrieves the gift exchange with the specified id.
     
     - Parameters:
        - id: The id used to identify the gift exchange
     
     - Returns: The identified gift exchange or a new gift exchange if the identified gift exchange was not found.
     */
    class func get(withId id: UUID) -> GiftExchange {
        if let giftExchange = GiftExchange.object(withId: id, context: PersistenceController.shared.context) {
            // we found the GiftExchange object in CoreData
            return giftExchange
        } else {
            // otherwise, return a new GiftExchange
            return GiftExchange.add()
        }
    }
    
    /**
    Initializes a new gift exchange with default values.
     
     - Returns: A new gift exchange.
     */
    private class func add() -> GiftExchange {
        let newGiftExchange = GiftExchange(context: PersistenceController.shared.context)
        return newGiftExchange
    }
    
    /**
     Initializes a new gift exchange with the provided form data.
     
     - Parameters:
        - data: The form data used to initialize the gift exchange
     
     - Returns: A new gift exchange.
     */
    class func add(using data: GiftExchangeFormData) -> GiftExchange {
        let newGiftExchange = GiftExchange.add()
        newGiftExchange.initId(from: data)
        newGiftExchange.updateValues(from: data)
        return newGiftExchange
    }
    
    /**
     Updates the gift exchange with the provided form data.
     
     - Parameters:
        - data: The form data used to update the gift exchange
     
     - Returns: The updated gift exchange.
     */
    class func update(using data: GiftExchangeFormData) -> GiftExchange {
        if let giftExchange = GiftExchange.object(withId: data.id, context: PersistenceController.shared.context) {
            // if we can find a GiftExchange object in CoreData, use it
            giftExchange.updateValues(from: data)
            return giftExchange
        } else {
            // otherwise, create a new GiftExchange from the provided data
            return GiftExchange.add(using: data)
        }
    }
    
    /**
     Deletes the specified gift exchange from CoreData.
     
     - Parameters:
        - giftExchange: The gift exchange to be deleted
    */
    class func delete(_ giftExchange: GiftExchange) {
        // remove the reference to this gift exchange from its associated gifters
        // by resetting its (real, Core Data) gifters to nil
        giftExchange.gifters_ = nil
        // now delete and save
        let context = giftExchange.managedObjectContext
        context?.delete(giftExchange)
        try? context?.save()
    }
    
    
}

extension GiftExchange: Comparable {
    
    
    // MARK: - Conform to Comparable
    
    // equatability is based on the unique id of the GiftExchange
    public static func == (lhs: GiftExchange, rhs: GiftExchange) -> Bool {
        return lhs.id == rhs.id
    }
    
    // order is based on a GiftExchange's name
    public static func < (lhs: GiftExchange, rhs: GiftExchange) -> Bool {
        return lhs.name < rhs.name
    }
    
}
