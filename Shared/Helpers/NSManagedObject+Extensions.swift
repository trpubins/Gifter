//
//  NSManagedObject+Extensions.swift
//  Shared (Model)
//
//  Created by Tanner on 8/7/21.
//

import CoreData


// Support for adding to many-to-many relationships
extension NSManagedObject {
    
    
    // MARK: Class Functions
    
    /**
     Finds an NSManagedObject with the specified id.
     
     - Parameters:
        - id: The unique id of the NSManagedObject
        - context: The managed object context to fetch results from
     
     - Returns: An instance of the NSManagedObject or nil if no object was found in the context.
     */
    class func object(withId id: UUID, context: NSManagedObjectContext) -> Self? {
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
    
    /**
     Finds an NSManagedObject with the specified email address (there should only be one, really).
     
     - Parameters:
        - email: The email address of the NSManagedObject
        - context: The managed object context to fetch results from
     
     - Returns: An instance of the NSManagedObject or nil if no object was found in the context.
     */
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
    
    /**
     Searches the context using an array of ids to retrieve an array of NSManagedObjects that the ids map to. The NSManagedObject must conform to Comparable.
     
     - Parameters:
        - entity: The NSManagedObject class type
        - idArr: The array of unique ids
        - context: The managed object context to fetch results from
     
     - Returns: A sorted array of generic objects that map to the provided ids.
     */
    class func objectArr<T: NSManagedObject>(entity:T.Type, withIdArr idArr: [UUID], context: NSManagedObjectContext) -> [T] where T: Comparable {
        var objects: [T] = []
        for id in idArr {
            guard let obj = T.object(withId: id, context: context) else {
                continue
            }
            objects.append(obj)
        }
        return objects.sorted()
    }
    
    /**
     Searches the context using an array of ids to retrieve an array of NSManagedObjects that the ids map to.
     
     - Parameters:
        - entity: The NSManagedObject class type
        - idArr: The array of unique ids
        - context: The managed object context to fetch results from
     
     - Returns: An unsorted array of generic objects that map to the provided ids.
     */
    class func objectArr<T: NSManagedObject>(entity:T.Type, withIdArr idArr: [UUID], context: NSManagedObjectContext) -> [T] {
        var objects: [T] = []
        for id in idArr {
            guard let obj = T.object(withId: id, context: context) else {
                continue
            }
            objects.append(obj)
        }
        return objects
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
