//
//  MockCoreDataContainer.swift
//  Tests
//
//  Created by Nuno Grilo on 29/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation
import CoreData
@testable import Sherpany_Posts

class MockCoreDataContainer: CoreDataContainer {
    
    override func newBackgroundManagedObjectContext() -> NSManagedObjectContext {
        if bgManagedObjectContext == nil {
            let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            managedObjectContext.parent = mainManagedObjectContext
            managedObjectContext.automaticallyMergesChangesFromParent = true
            managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            bgManagedObjectContext = managedObjectContext
        }
        return bgManagedObjectContext!
    }
    
    private var bgManagedObjectContext: NSManagedObjectContext?
}
