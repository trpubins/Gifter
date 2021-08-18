//
//  NSManagedObject+Extensions.swift
//  Shared (Model)
//
//  Created by Tanner on 8/7/21.
//

import CoreData

// Support adding to many-to-many relationships

extension NSManagedObject {
    
    
    // MARK: Class Functions
    
    // finds an NSManagedObject with the given UUID
    class func object(withID id: UUID, context: NSManagedObjectContext) -> Self? {
        let fetchRequest: NSFetchRequest<Self> = NSFetchRequest<Self>(entityName: Self.description())
        fetchRequest.predicate = NSPredicate(format: "id_ == %@", id as CVarArg)
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch let error as NSError {
            NSLog("Error fetching NSManagedObjects \(Self.description()): \(error.localizedDescription), \(error.userInfo)")
        }
        return nil
    }
    
    // finds an NSManagedObject with the given email address (there should only be one, really)
    class func object(withEmail email: String, context: NSManagedObjectContext) -> Self? {
        let fetchRequest: NSFetchRequest<Self> = NSFetchRequest<Self>(entityName: Self.description())
        fetchRequest.predicate = NSPredicate(format: "email_ == %@", email as CVarArg)
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch let error as NSError {
            NSLog("Error fetching NSManagedObjects \(Self.description()): \(error.localizedDescription), \(error.userInfo)")
        }
        return nil
    }
    
    // MARK: Object Methods
    
    /**
     Adds an object to the NSManagedObject property matching the provided key.
     
     - Parameters:
        - value: The object to be added
        - key: The name of the property inside the NSManagedObject class
     */
    func addObject(value: NSManagedObject, forKey key: String) {
        let items = self.mutableSetValue(forKey: key)
        items.add(value)
    }
    
    /**
     Removes an object from the NSManagedObject property matching the provided key.
     
     - Parameters:
     - value: The object to be removed
     - key: The name of the property inside the NSManagedObject class
     */
    func removeObject(value: NSManagedObject, forKey key: String) {
        let items = self.mutableSetValue(forKey: key)
        items.remove(value)
    }
    
}
