//
//  CoreDataContainer.swift
//  Tests
//
//  Created by Nuno Grilo on 29/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation
import CoreData

/// Subclasses from `NSPersistentContainer` and setups the Core Data Stack for this app.
///
/// There are multiple possible Core Data Stacks, each one with its advantages
/// and disadvantages. The stack below was adapted because, although the merging
/// process takes longer than other stack setups, the UI is not blocked so the
/// app keeps responsive all the time.
class CoreDataContainer: NSPersistentContainer {
    
    
    // MARK: - Core Data contexts
    
    /// Private background context that actually writes to persistent store.
    lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        managedObjectContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return managedObjectContext
    }()
    
    /// The main, readonly context, has the private context as parent.
    /// Automatically merge changes from parent (private context).
    /// Merge policy is set to prefer store version (since context is read-only).
    lazy var mainManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = privateManagedObjectContext
        managedObjectContext.automaticallyMergesChangesFromParent = true
        managedObjectContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        return managedObjectContext
    }()
    
    /// Creates a new background context to perform long/write operations.
    /// Context saves immediatelly propagate changes to the persistent store
    /// (and down, to the main context).
    /// Merge policy is set to prefer in-memory version over store version.
    func newBackgroundManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        managedObjectContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return managedObjectContext
    }
    
    
    // MARK: - Convenience overrides
    
    override var viewContext: NSManagedObjectContext {
        return mainManagedObjectContext
    }
    
    override func newBackgroundContext() -> NSManagedObjectContext {
        return newBackgroundManagedObjectContext()
    }
    
}
