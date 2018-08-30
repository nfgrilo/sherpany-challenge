//
//  CoreDataContainer.swift
//  Tests
//
//  Created by Nuno Grilo on 29/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation
import CoreData

class CoreDataContainer: NSPersistentContainer {
    
    /// The main, readonly context, has the persistent store as its parent.
    /// Context saves persist changes to persistent store.
    lazy var mainManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        managedObjectContext.automaticallyMergesChangesFromParent = true
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return managedObjectContext
    }()
    
    /// Creates a new background context to perform write operations.
    /// Context saves immediatelly propagate changes to the `mainManagedObjectContext`.
    func newBackgroundManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.parent = mainManagedObjectContext
        managedObjectContext.automaticallyMergesChangesFromParent = true
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return managedObjectContext
    }
    
    /// Background context to perform write operations.
    /// Context saves immediatelly propagate changes to the `mainManagedObjectContext`.
    lazy var backgroundManagedObjectContext: NSManagedObjectContext = {
        return newBackgroundManagedObjectContext()
    }()
    
    /// Save changes to disk.
    func saveToPersistentStore() {
        DispatchQueue.main.async { [weak self] in
            if let context = self?.mainManagedObjectContext, context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Failed to save to Core Data persistent store: \(error).")
                }
            }
        }
    }
    
}
