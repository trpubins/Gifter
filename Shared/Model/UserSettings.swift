//
//  UserSettings.swift
//  Shared (Model)
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
    @Published var idList: [UUID]? {
        didSet {
            encode(property: idList, key: "giftExchangeList")
        }
    }
    
    /// The id of the user's selected GiftExchange
    @Published var idSelected: UUID? {
        didSet {
            encode(property: idSelected, key: "giftExchangeSelected")
        }
    }
    
    
    // MARK: Initializer
    
    /**
     Initializes the GiftExchange properties by decoding them from the user defaults.
     */
    init() {
        self.idList = decode(type: [UUID].self, key: "giftExchangeList")
        self.idSelected = decode(type: UUID.self, key: "giftExchangeSelected")
    }
    
    
    // MARK: Object Functions
    
    /**
     Adds a GiftExchange id to the user settings.
     
     - Parameters:
        - id: The GiftExchange id to add
     */
    public func addGiftExchangeId(id: UUID) {
        // add to the list
        if self.idList == nil {
            self.idList = [id]
        } else {
            self.idList!.append(id)
        }
        
        // add to the selected id
        self.idSelected = id
    }
    
    /**
     Removes the selected GiftExchange id from the user settings.
     */
    public func removeSelectedGiftExchangeId() {
        // use guard to to perform optional binding to new variable
        guard var idList = self.idList else {
            self.idList = nil
            self.idSelected = nil
            return
        }
        // at this point, compiler knows idList is not nil so force unwrapping is not necessary
        
        // update list by removing selected id
        idList = idList.filter {$0 != self.idSelected}  // removes the selected id from the id list by value
        
        // set properties to nil if the id list is empty after removing the selected id
        if idList.isEmpty {
            self.idList = nil
            self.idSelected = nil
            return
        }
        
        // update properties from non-empty id list
        self.idList = idList
        self.idSelected = idList.first  // assing first id in list to the selected id
    }
    
    
    // MARK: Private Functions
    
    /**
     Attempts to encode a property into the user defaults store with the provided key.
     
     - Parameters:
        - property: The class property to encode
        - key: The user defaults dictionary key
     */
    private func encode<T>(property: T?, key: String) {
        // perform optional binding
        guard let unwrappedProperty = property else {
            userDefaults.set(nil, forKey: key)
            return
        }
        
        // attempt to encode and save to the user defaults
        do {
            let encoded = try NSKeyedArchiver.archivedData(withRootObject: unwrappedProperty, requiringSecureCoding: false)
            userDefaults.set(encoded, forKey: key)
        } catch {
            fatalError("Could not encode GiftExchangeSettings property. \(error)")
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
            fatalError("Could not decode GiftExchangeSettings variable of type \(type). \(error)")
        }
    }
    
}
