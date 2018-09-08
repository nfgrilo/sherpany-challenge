//
//  PostsCoordinatorTests.swift
//  Tests
//
//  Created by Nuno Grilo on 08/09/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import XCTest
import UIKit
@testable import Sherpany_Posts

class PostsCoordinatorTests: XCTestCase {
    
    // MARK: - Setup
    
    var coordinator: PostsCoordinator!
    var modelController: ModelController!
    var apiController: APIController!
    var dataController: DataController!
    var mockSession: URLSessionMock!
    var fakeData: FakeData!
    
    var navigationController: UINavigationController!
    
    
    override func setUp() {
        super.setUp()
        
        // initialize mock URL session
        mockSession = URLSessionMock()

        // initialize controllers
        apiController = APIController(session: mockSession)
        dataController = MockDataController()
        let eDataController = XCTestExpectation(description: "Data controller loaded persistent store")
        dataController.loadPersistentStore { [unowned self] _, _ in
            defer { eDataController.fulfill() }
            
            // model controller
            self.modelController = ModelController(dataController: self.dataController, apiController: self.apiController)
            
            // initialize fake data
            self.fakeData = FakeData()
            self.fakeData.createFakeData(in: self.dataController.backgroundManagedObjectContext)
        }
        wait(for: [eDataController], timeout: 1)

        // navigation controller
        navigationController = UINavigationController(rootViewController: UIViewController())
        
        // create the posts coordinator
        coordinator = PostsCoordinator(navigationController: navigationController, modelController: modelController)
    }
    
    override func tearDown() {
        // clean up
        coordinator = nil
        
        super.tearDown()
    }
    
    
    // MARK: - start()
    
    func test_start() {
        let previousDelegatesCount = modelController.registeredDelegates().count
        
        // start coordinator
        coordinator.start()
        
        // assert coordinator is a model controller delegate
        XCTAssertEqual(modelController.registeredDelegates().count, previousDelegatesCount + 1, "Coordinator registered as delegate")
        
        // assert view controller setup
        XCTAssertNotNil(coordinator.viewController, "View controller was setup")
        
        // assert data source setup
        XCTAssertNotNil(coordinator.dataSource, "Data source was setup")
        
        // assert search setup
        XCTAssertNotNil(coordinator.searchController, "Search controller was setup")
        XCTAssertEqual(coordinator.dataSource?.searchController, coordinator.searchController, "Search controller was setup on data source")
        
        // assert navigation
        XCTAssertTrue(navigationController.topViewController === coordinator.viewController, "Top view controller is correct")
    }
    
    
    // MARK: - createViewController()
    
    func test_createViewController() {
        let vc = coordinator.createViewController()
        
        // assert correct setup
        XCTAssertNotNil(vc, "View controller is not nil")
        XCTAssertEqual(vc?.title, "Posts", "View controller title is correct")
    }
    
    
    // MARK: - createDataSource(for:)
    
    func test_createDataSource() {
        let tableView = UITableView(frame: .zero)
        let dataSource = coordinator.createDataSource(for: tableView)
        
        // assert view controller setup
        XCTAssertEqual(dataSource.tableView, tableView, "Data source table view weak ref was set")
        XCTAssertTrue(dataSource === tableView.dataSource, "Table view data source was set correctly")
        XCTAssertTrue(dataSource === tableView.delegate, "Table view delegate was set correctly")
    }
    
    
    // MARK: - loadInitialData(in:completion:)
    
    func test_loadInitialData() {
        let tableView = UITableView(frame: .zero)
        let dataSource = coordinator.createDataSource(for: tableView)
        coordinator.dataSource = dataSource
        
        // assert data was loaded
        let e = XCTestExpectation(description: "Data source loaded initial data")
        coordinator.loadInitialData(in: tableView) { [weak self] in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            XCTAssertTrue(self?.coordinator.dataSource?.activeModel().count ?? 0 > 0, "Data source has loaded data")
        }
        wait(for: [e], timeout: 1)
    }
    
    
    // MARK: - createSearchController(on:resultsUpdater:)
    
    func test_createSearchController() {
        let viewController = UIViewController()
        let updater = TestSearchResultsUpdating()
        let searchController = coordinator.createSearchController(on: viewController, resultsUpdater: updater)
        
        // assert search controller setup
        XCTAssertNotNil(searchController, "Search controller was set")
        XCTAssertTrue(searchController.searchResultsUpdater === updater, "Search controller results updater was set correctly")
        XCTAssertFalse(searchController.searchBar.placeholder?.isEmpty ?? true, "Search bar placeholder text was set")
        XCTAssertEqual(searchController, viewController.navigationItem.searchController, "Navigation item search controller was correctly set")
    }
    
    
    // MARK: - setupNavigationBar()
    
    func test_setupNavigationBar() {
        coordinator.setupNavigationBar()
        
        // assert colors make text readable
        let barTintColor = navigationController.navigationBar.barTintColor
        XCTAssertFalse(barTintColor == .clear, "Navigation bar tint color was set to named color (not .clear)")
        XCTAssertTrue(navigationController.navigationBar.barStyle == .black, "Navigation bar style was set to black")
    }
    
    // MARK: - PostsDataSourceDelegate conformance: postWasSelected(_)
    
    func test_postWasSelected() {
        let tableView = UITableView(frame: .zero)
        let dataSource = coordinator.createDataSource(for: tableView)
        let post = Post(id: 99, title: "Post 99", body: "Post 99 body", user: nil)
        let postsCoordinatorDelegate = PostsCoordinatorTestsDelegate()
        coordinator.delegate = postsCoordinatorDelegate
        
        // assert PostsCoordinatorDelegate.postWasSelected(postId:) is called
        let eDelegate = XCTestExpectation(description: "PostsCoordinatorDelegate postWasSelected(postId:) was invoked")
        postsCoordinatorDelegate.postWasSelectedClosure = { postId in
            defer { eDelegate.fulfill() }
            
            XCTAssertEqual(postId, post.id, "PostsCoordinatorDelegate postWasSelected(postId:) was invoked with correct post id")
        }
        // trigger action on datasource delegate
        dataSource.delegate?.postWasSelected(post)
        //
        wait(for: [eDelegate], timeout: 1)
        
        // assert selected post is correct
        XCTAssertEqual(post, coordinator.selectedPost, "Selected post is correct")
        
        coordinator.delegate = nil
    }
    
    // MARK: - PostsDataSourceDelegate conformance: postWasDeleted(_)
    
    func test_postWasDeleted() {
        // nothing to test
    }
    
    // MARK: - PostsDataSourceDelegate conformance: searchFeedbackDidChange(_)
    
    func test_searchFeedbackDidChange() {
        let viewController = TestPostsViewController()
        coordinator.viewController = viewController
        let dataSource = coordinator.createDataSource(for: viewController.tableView)
        
        // trigger action on datasource delegate
        let feedbackText = "Hello world 😃!"
        dataSource.delegate?.searchFeedbackDidChange(feedbackText)
        
        // assert feedback text is correct
        XCTAssertEqual(viewController.searchFeedbackText, feedbackText, "Search feedback text was updated")
    }
    
    // MARK: - ModelControllerDelegate conformance: postWasRemoved(postId:)
    
    func test_postWasRemoved() {
        // nothing to test
    }
    
    // MARK: - ModelControllerDelegate conformance: dataWillRefresh()
    
    func test_dataWillRefresh() {
        let viewController = TestPostsViewController()
        coordinator.viewController = viewController
        modelController.addDelegate(coordinator)
        XCTAssertTrue(modelController.registeredDelegates().count == 1, "Unexpected ModelController delegates count")
        
        // invoke delegate method
        let eNotifyDelegates = XCTestExpectation(description: "ModelController invoked delegate.dataWillRefresh()")
        modelController.notifyDelegates { (modelControllerDelegate) in
            defer { eNotifyDelegates.fulfill() }
            modelControllerDelegate.dataWillRefresh()
        }
        wait(for: [eNotifyDelegates], timeout: 1)
        
        // assert dataWillRefresh() call
        let eDelegate = XCTestExpectation(description: "ModelControllerDelegate.dataWillRefresh() was invoked")
        DispatchQueue.main.async { [weak self] in
            defer { eDelegate.fulfill() }
            
            // assert feedback view is visible
            XCTAssertTrue(viewController.isProgressViewVisible, "Feedback view is visible")
        }
        wait(for: [eDelegate], timeout: 1)
        
        // clean up
        modelController.removeDelegate(coordinator)
    }
    
    // MARK: - ModelControllerDelegate conformance: dataDidRefresh()
    
    func test_dataDidRefresh() {
        let viewController = TestPostsViewController()
        coordinator.viewController = viewController
        modelController.addDelegate(coordinator)
        XCTAssertTrue(modelController.registeredDelegates().count == 1, "Unexpected ModelController delegates count")
        let dataSource = coordinator.createDataSource(for: viewController.tableView)
        coordinator.dataSource = dataSource
        XCTAssertTrue(dataSource.postsCount() == 0, "Data source is empty")
        
        // invoke delegate method
        let eNotifyDelegates = XCTestExpectation(description: "ModelController invoked delegate.dataDidRefresh()")
        modelController.notifyDelegates { (modelControllerDelegate) in
            defer { eNotifyDelegates.fulfill() }
            modelControllerDelegate.dataDidRefresh(success: true)
        }
        wait(for: [eNotifyDelegates], timeout: 1)
        
        // assert dataDidRefresh() call
        let eDelegate = XCTestExpectation(description: "ModelControllerDelegate.dataDidRefresh() was invoked")
        DispatchQueue.main.async { [weak self] in
            defer { eDelegate.fulfill() }
            
            // assert feedback view is visible
            XCTAssertFalse(viewController.isProgressViewVisible, "Feedback view is hidden")
            
            // assert data was loaded
            XCTAssertTrue(dataSource.postsCount() > 0, "Data was loaded into data source")
            
        }
        wait(for: [eDelegate], timeout: 1)
        
        // clean up
        modelController.removeDelegate(coordinator)
    }
    
}

class TestPostsViewController: UIViewController, PostsViewControllerProtocol {
    var tableView: UITableView! = UITableView()
    var isProgressViewVisible: Bool = false
    var searchFeedbackText: String? = nil
}

class TestSearchResultsUpdating: NSObject, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // dumb method - testing this functionality is Apple's responsability :D
    }
}

class PostsCoordinatorTestsDelegate: PostsCoordinatorDelegate {
    var postWasSelectedClosure: ((Int64?) -> Void)?
    
    func postWasSelected(postId: Int64?) {
        postWasSelectedClosure?(postId)
    }
}
