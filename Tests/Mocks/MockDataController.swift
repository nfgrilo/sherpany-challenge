//
//  MockDataController.swift
//  Tests
//
//  Created by Nuno Grilo on 08/09/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation
import CoreData
@testable import Sherpany_Posts

class MockDataController: DataController {
    
    /// Initialize a mocking model controller.
    init() {
        let appBundle = Bundle(for: AppDelegate.self)
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [appBundle])!
        
        super.init(modelName: "Posts", managedObjectModel: managedObjectModel)
    }
    
    override func setupContainer() {
        super.setupContainer()
        
        // setup container for a in-memory persistent store.
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]
    }
    
    override func loadPersistentStore(completion: ((NSPersistentStoreDescription, Error?) -> Void)?) {
        super.loadPersistentStore { (storeDescription, error) in
            // assert the data store is in-memory
            precondition(storeDescription.type == NSInMemoryStoreType)
            precondition(error == nil)

            completion?(storeDescription, error)
        }
    }
    
}
