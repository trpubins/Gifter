//
//  Persistence.swift
//  Shared (Model)
//
//  Created by Tanner on 7/16/21.
//

import CoreData

/// A controller for managing the persistent storage configured with CoreData.
struct PersistenceController {
    
    
    // MARK: Properties
    
    /// A global singleton for our entire app to use
    static let shared = PersistenceController()

    /// The model's storage container for CoreData
    let container: NSPersistentContainer

    
    // MARK: Computed Properties
    
    /// The shared managed object context
    var context: NSManagedObjectContext {
        // the property must be a var to be a computed property, but there shall be no intent to change its value
        get { container.viewContext }
        set { fatalError("PersistenceController static property `context` shall not be mutated.") }
    }

    
    // MARK: Initializer
    
    /**
     Initializes the persistent container with an option to load the store into memory. Made private so only we can instantiate these objects.
     
     - Parameters:
        - inMemory: Optional, set to `true` for loading the store into memory
     */
    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GifterStore")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // enable persistent history tracking
        guard let persistentStoreDescriptions = container.persistentStoreDescriptions.first else {
            fatalError("\(#function): Failed to retrieve a persistent store description.")
        }
        // necessary to listen for remote changes (e.g. cloud)
        // see documentation https://developer.apple.com/documentation/coredata/consuming_relevant_store_changes
        persistentStoreDescriptions.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        persistentStoreDescriptions.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
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
    
    
    // MARK: Object Methods
    
    /**
     Attempts to commit unsaved changes to the context’s parent store. But first checks to see if the context has any changes.
     */
    public func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
