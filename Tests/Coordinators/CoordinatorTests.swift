//
//  CoordinatorTests.swift
//  Tests
//
//  Created by Nuno Grilo on 08/09/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import XCTest
@testable import Sherpany_Posts

class CoordinatorTests: XCTestCase {
    
    // MARK: - Setup
    
    var coordinator: Coordinator!
    
    override func setUp() {
        super.setUp()
        
        // create a (base) coordinator
        coordinator = Coordinator()
    }
    
    override func tearDown() {
        super.tearDown()
        
        // clean up
        coordinator = nil
    }
    
    
    // MARK: - addChild()
    
    func test_addChild() {
        let child1 = Coordinator()
        let child2 = Coordinator()
        
        // add 1st child coordinator
        coordinator.addChild(child1)
        XCTAssertTrue(coordinator.childCoordinators.contains(child1), "Coordinator contains child1")
        XCTAssertTrue(coordinator.childCoordinators.count == 1, "Coordinator contains only one child")
        
        // add 2nd child coordinator
        coordinator.addChild(child2)
        XCTAssertTrue(coordinator.childCoordinators.contains(child2), "Coordinator contains child2")
        XCTAssertTrue(coordinator.childCoordinators.count == 2, "Coordinator contains two children")
        
        coordinator.childCoordinators.removeAll()
    }
    
    
    // MARK: - removeChild()
    
    func test_removeChild() {
        let child1 = Coordinator()
        let child2 = Coordinator()
        
        // add child coordinators
        coordinator.addChild(child1)
        coordinator.addChild(child2)
        XCTAssertTrue(coordinator.childCoordinators.contains(child1), "Coordinator contains child1")
        XCTAssertTrue(coordinator.childCoordinators.contains(child2), "Coordinator contains child2")
        XCTAssertTrue(coordinator.childCoordinators.count == 2, "Coordinator contains two children")
        
        // remove 2nd child coordinator
        coordinator.removeChild(child2)
        XCTAssertTrue(coordinator.childCoordinators.contains(child1), "Coordinator contains child1")
        XCTAssertFalse(coordinator.childCoordinators.contains(child2), "Coordinator does not contain child2")
        XCTAssertTrue(coordinator.childCoordinators.count == 1, "Coordinator contains one child")
        
        // remove 1st child coordinator
        coordinator.removeChild(child1)
        XCTAssertFalse(coordinator.childCoordinators.contains(child1), "Coordinator does not contain child1")
        XCTAssertFalse(coordinator.childCoordinators.contains(child2), "Coordinator does not contain child2")
        XCTAssertTrue(coordinator.childCoordinators.isEmpty, "Coordinator contains no children")
    }
    
}
