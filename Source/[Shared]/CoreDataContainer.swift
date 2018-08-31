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
    
    // MARK: - Core Data contexts
    
    /// The main, read-only context, has the persistent store as parent.
    /// Automatically merge changes from store.
    lazy var mainManagedObjectContext: NSManagedObjectContext = {
        viewContext.automaticallyMergesChangesFromParent = true
        
        // Merge policy is set to prefer store version over in-memory version (since context is read-only).
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        
        return viewContext
    }()
    
    /// Background context to perform long/write operations.
    /// Context saves immediatelly propagate changes to the persistent store.
    lazy var backgroundManagedObjectContext: NSManagedObjectContext = {
        let context = newBackgroundContext()
        
        // Merge operations should occur on a property basis (`id` attribute)
        // and the in memory version “wins” over the persisted one.
        // All entities have been modeled with an `id` constraint.
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        return context
    }()
    
}
