//
//  Persistence.swift
//  Shared (Model)
//
//  Created by Tanner on 7/16/21.
//

import CoreData

/// A controller for managing the persistent storage configured with CoreData.
struct PersistenceController {
    /// A global singleton for our entire app to use
    static let shared = PersistenceController()

    /// The model's storage container for CoreData
    let container: NSPersistentContainer
    
    /// A test configuration intended for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
//        for _ in 0..<10 {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//        }
        saveContext(context: viewContext)
        return controller
    }()

    /**
     Initializes the persistent container with an option to load the store into memory.
     
     - Parameters:
        - inMemory: Optional, set to `true` for loading the store into memory
     */
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Gifter")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}

/**
 Checks to see if the context has any changes. Then, attempts to commit unsaved changes to the context’s parent store.
 
 - Parameters:
    - context: The managed object context to be saved
 */
public func saveContext(context: NSManagedObjectContext) {
    if context.hasChanges {
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
