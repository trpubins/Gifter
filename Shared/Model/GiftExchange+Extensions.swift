//
//  GiftExchange+Extensions.swift
//  Shared (Model)
//
//  Created by Tanner on 8/6/21.
//

import Foundation
import CoreData

/// A gift exchange, which holds meta data and acts as a container for an array of gifters.
extension GiftExchange {
    
    
    // MARK: Property Wrappers
    
    public var id: UUID {
        get { id_ ?? UUID() }
    }
    
    public var date: Date {
        get { date_ ?? Date() }
        set { date_ = newValue }
    }
    
    public var name: String {
        get { name_ ?? "Unknown name" }
        set { name_ = newValue }
    }
    
    /// The emoji to identify the GiftExchange
    public var emoji: String {
        get { emoji_ ?? emojis.first! }
        set { emoji_ = newValue }
    }
    
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
    
    
    // MARK: Class Functions
    
    class func addNewGiftExchange() -> GiftExchange {
        let newGiftExchange = GiftExchange(context: PersistenceController.shared.context)
        return newGiftExchange
    }
    
    class func addNewGiftExchange(using data: GiftExchangeFormData) -> GiftExchange {
        let newGiftExchange = addNewGiftExchange()
        newGiftExchange.initId(from: data)
        newGiftExchange.updateValues(from: data)
        return newGiftExchange
    }
    
    class func update(using data: GiftExchangeFormData) -> GiftExchange {
        if let giftExchange = GiftExchange.object(withID: data.id, context: PersistenceController.shared.context) {
            // if we can find a GiftExchange object in CoreData, use it
            giftExchange.updateValues(from: data)
            return giftExchange
        } else {
            // otherwise, create a new GiftExchange from the provided data
            return addNewGiftExchange(using: data)
        }
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
