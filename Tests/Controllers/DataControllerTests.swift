//
//  DataControllerTests.swift
//  Tests
//
//  Created by Nuno Grilo on 08/09/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import XCTest
import CoreData
@testable import Sherpany_Posts

class DataControllerTests: XCTestCase {
    
    // MARK: - Setup
    
    var dataController: DataController!
    
    override func setUp() {
        super.setUp()
        
        let appBundle = Bundle(for: AppDelegate.self)
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [appBundle])!
        dataController = DataController(modelName: "Posts", managedObjectModel: managedObjectModel)
    }
    
    override func tearDown() {
        dataController = nil
        
        super.tearDown()
    }
    
    // MARK: - setupContainer()
    
    func test_setupContainer() {
        // default implementation does nothing
        XCTAssertTrue(dataController.containerWasSetup, "Persistent container was set up")
    }
    
    // MARK: - loadPersistentStore()
    
    func test_loadPersistentStore() {
        let e = XCTestExpectation(description: "Persistent store was loaded")
        
        // assert persistent store is loaded
        dataController.loadPersistentStore { (_, _) in
            defer { e.fulfill() }
        }
        wait(for: [e], timeout: 1)
    }
    
    // MARK: - mainManagedObjectContext
    
    func test_mainManagedObjectContext() {
        let context = dataController.mainManagedObjectContext
        
        XCTAssertNotNil(context, "Main context is not nil")
        XCTAssertEqual(context.concurrencyType, .mainQueueConcurrencyType, "Concurrency type was correctly set")
        XCTAssertTrue(context.automaticallyMergesChangesFromParent, "Context set to update from parent")
        XCTAssertTrue(context.mergePolicy as AnyObject === NSMergeByPropertyStoreTrumpMergePolicy, "Merge policy was correctly set")
    }
    
    // MARK: - backgroundManagedObjectContext
    
    func test_backgroundManagedObjectContext() {
        let context = dataController.backgroundManagedObjectContext
        
        XCTAssertNotNil(context, "Background context is not nil")
        XCTAssertEqual(context.concurrencyType, .privateQueueConcurrencyType, "Concurrency type was correctly set")
        XCTAssertFalse(context.automaticallyMergesChangesFromParent, "Context merge changes from parent setting correctly set")
        XCTAssertTrue(context.mergePolicy as AnyObject === NSMergeByPropertyObjectTrumpMergePolicy, "Merge policy was correctly set")
    }
    
}
