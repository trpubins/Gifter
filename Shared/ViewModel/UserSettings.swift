//
//  UserSettings.swift
//  Shared (ViewModel)
//  https://www.simpleswiftguide.com/how-to-use-userdefaults-in-swiftui/
//  https://stackoverflow.com/a/41355671
//
//  Created by Tanner on 8/8/21.
//

import Foundation
import Combine

/// For saving app configuration data
public let userDefaults = UserDefaults.standard

/// Stores settings related to the user's associated gift exchanges into the UserDefaults persistent store.
class UserSettings: ObservableObject {
    
    
    // MARK: Published Properties
    
    /// A list of GiftExchange ids associated with the user
    @Published var idList: [UUID] = [] {
        didSet {
            encode(property: self.idList, key: "giftExchangeList")
        }
    }
    
    /// Automatically restricts gifters from matching in consecutive gift exchanges if `true`
    @Published var autoRestrictions: Bool = true {
        didSet {
            encode(property: self.autoRestrictions, key: "autoRestrictions")
        }
    }

    
    // MARK: Computed Properties
    
    /// The id of the user's selected GiftExchange
    var selectedId: UUID? {
        get { return self.idList.first }
    }

    /// An array of ids that are not the selected GiftExchange
    var unselectedIdList: [UUID] {
        get {
            if self.hasMultipleGiftExchanges() {
                var unselectedIdList = self.idList  // arrays are passed by value
                unselectedIdList.removeFirst()  // remove the first element, which is the selected id
                return unselectedIdList
            } else {
                return []
            }
        }
    }
    
    
    // MARK: Initializer
    
    /**
     Initializes the settings properties by decoding them from the user defaults.
     */
    init() {
        self.idList = decode(type: [UUID].self, key: "giftExchangeList") ?? []
        self.autoRestrictions = decode(type: Bool.self, key: "autoRestrictions") ?? true
    }
    
    
    // MARK: Object Methods
    
    /**
     Used to determine if the user has more than one gift exchange saved.
     
     - Returns: `true` if user has more than one gift exchange, `false` otherwise
     */
    public func hasMultipleGiftExchanges() -> Bool {
        return self.idList.count > 1
    }
    
    /**
     Adds a GiftExchange id to the user settings. Makes the provided id the selected GiftExchange id.
     Also, triggers a refresh to any Views observing this UserSettings object.
     
     - Parameters:
        - id: The GiftExchange id to add
     */
    public func addGiftExchangeId(id: UUID) {
        // add to the front of the list
        self.idList.insert(id, at: 0)
    }
    
    /**
     Removes the selected GiftExchange id from the user settings. Does not perform removal if there is only 1 associated GiftExchange.
     
     - Returns: `true` if the selected id was removed, `false` otherwise.
     */
    @discardableResult
    public func removeSelectedGiftExchangeId() -> Bool {
        if self.hasMultipleGiftExchanges() {
            // update list by removing the first element, which is the selected id
            self.idList.removeFirst()
            return true
        } else {
            // do not perform removal if there is only 1 associated gift exchange
            return false
        }
    }
    
    /**
     Changes the selected id to the specified id if it exists in the idList.
     
     - Parameters:
        - id: The GiftExchange id to select (switch to)
     
     - Returns: `true` if the selected id was successfully changed, `false` if the specified id was not in the list of ids.
     */
    @discardableResult
    public func changeSelectedGiftExchangeId(id: UUID) -> Bool {
        if self.idList.contains(id) {
            self.idList = self.idList.filter {$0 != id}  // filter the id out
            self.idList.insert(id, at: 0)  // then add it back to make it the selected id
            return true
        } else {
            return false
        }
    }
    
    
    // MARK: Private Functions
    
    /**
     Attempts to encode a property into the user defaults store with the provided key.
     
     - Parameters:
        - property: The class property to encode
        - key: The user defaults dictionary key
     */
    private func encode<T>(property: T, key: String) {
        // attempt to encode and save to the user defaults
        do {
            let encoded = try NSKeyedArchiver.archivedData(withRootObject: property, requiringSecureCoding: false)
            userDefaults.set(encoded, forKey: key)
            return
        } catch {
            fatalError("Could not encode UserSettings property. \(error)")
        }
    }

    /**
     Attempts to decode bytes stored in the user defaults at the provided key.
     
     - Parameters:
        - type: The Swift type that is attempted to be decoded
        - key: The user defaults dictionary key
     
     - Returns: The decoded data or `nil` if the key does not exist in user defaults.
     */
    private func decode<T>(type: T.Type, key: String) -> T? {
        // perform optional binding
        guard let rawData = userDefaults.object(forKey: key) as? Data else {
            return nil
        }
        
        // attempt to decode the raw data
        do {
            let decoded = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(rawData) as? T
            return decoded
        } catch {
            fatalError("Could not decode UserSettings data as type \(type). \(error)")
        }
    }
    
}
