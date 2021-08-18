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
        id_ ?? UUID()
    }
    
    public var date: Date {
        date_ ?? Date()
    }
    
    public var name: String {
        name_ ?? "Unknown name"
    }
    
    public var gifters: [Gifter] {
        let set = gifters_ as? Set<Gifter> ?? []
        return set.sorted {
            $0.name < $1.name
        }
    }
    
    
    // MARK: Object Methods
    
    private func updateValues(from data: GiftExchangeFormData) {
        id_ = data.id
        date_ = data.date
        name_ = data.name
    }
    
    
    // MARK: Class Functions
    
    class func update(using data: GiftExchangeFormData) {
        if let giftExchange = GiftExchange.object(withID: data.id, context: PersistenceController.shared.context) {
            // if we can find a GiftExchange object in CoreData, use it
            giftExchange.updateValues(from: data)
        } else {
            // otherwise, create a new GiftExchange from the provided data
            let newGiftExchange = GiftExchange(context: PersistenceController.shared.context)
            newGiftExchange.updateValues(from: data)
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
