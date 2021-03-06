//
//  Tests.swift
//  Tests
//
//  Created by Nuno Grilo on 28/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import XCTest
import CoreData
@testable import Sherpany_Posts

class ModelControllerTests: XCTestCase {
    
    // MARK: - Setup
    
    var modelController: ModelController!
    var apiController: APIController!
    var dataController: DataController!
    var mockSession: URLSessionMock!
    var fakeData: FakeData!
    
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
    }
    
    override func tearDown() {
        // clean up
        mockSession = nil
        fakeData.removeFakeData(in: dataController.backgroundManagedObjectContext)
        fakeData = nil
        apiController = nil
        
        super.tearDown()
    }
    
    
    // MARK: - allPosts()
    
    func test_allPosts() {
        // setup expected data
        let e = XCTestExpectation(description: "Got persisted posts from Core Data")
        
        //
        modelController.allPosts { posts in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // assertions
            XCTAssert(posts.count == 2, "Posts found on Core Data")
        }
        wait(for: [e], timeout: 1)
    }
    
    
    // MARK: - post(with:completion:)
    
    func test_Post() {
        let e = XCTestExpectation(description: "Got a post from Core Data")
        modelController.post(with: 1) { post in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // assertions
            XCTAssertNotNil(post, "Found post")
            guard let post = post else { return }
            XCTAssertEqual(post.id, 1, "Post have expected `id`")
            XCTAssertEqual(post.title, "Post 1", "Post have expected `title`")
            XCTAssertEqual(post.user?.id ?? 0, 1, "Post have expected `user`")
        }
        wait(for: [e], timeout: 1)
    }
    
    func test_post_notFound() {
        let e = XCTestExpectation(description: "Got no post from Core Data")
        modelController.post(with: 999999) { post in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // assertions
            XCTAssertNil(post, "Post not found")
        }
        wait(for: [e], timeout: 1)
    }
    
    
    // MARK: - removePost(_:completion:)
    
    func test_removePost() {
        // expectations
        let eCompletion = XCTestExpectation(description: "Remove a post from Core Data (completion closure + post delete confirmation)")
        let eDelegate = XCTestExpectation(description: "Remove a post from Core Data (delegate method)")
        
        // delegate
        let delegate = ModelControllerTestsDelegate()
        delegate.postWasRemovedClosure = { [weak self] in
            // clean up delegate
            if let selfInstance = self {
                self?.modelController.removeDelegate(delegate)
            }
            // fullfill expectation on return
            eDelegate.fulfill()
        }
        modelController.addDelegate(delegate)
        
        // remove post
        modelController.removePost(1) { [weak self] in
            // get post
            self?.modelController.post(with: 1) { post in
                defer { eCompletion.fulfill() /* fullfill expectation on return */ }
                
                XCTAssertNil(post, "Post was removed")
            }
        }
        wait(for: [eCompletion, eDelegate], timeout: 1)
    }
    
    func test_removePost_whileRefreshingData() {
        // setup expected data
        mockSession.expectedData = { [weak self] url in
            Thread.sleep(forTimeInterval: 0.250) // intentionally slow down process
            if url.pathComponents.contains("posts") {
                return self?.fakeData.allPostsData
            }
            else if url.pathComponents.contains("users") {
                return self?.fakeData.allUsersData
            }
            else if url.pathComponents.contains("albums") {
                return self?.fakeData.allAlbumsData
            }
            else if url.pathComponents.contains("photos") {
                return self?.fakeData.allPhotosData
            }
            return nil
        }
        mockSession.expectedError = nil
        
        // initiate a data refresh
        let eDataFetched = XCTestExpectation(description: "Data fetched & merged")
        let ePostNotRemoved = XCTestExpectation(description: "Post not removed?")
        let ePostRemoved = XCTestExpectation(description: "Post removed")
        modelController.refreshDataOnline() { [weak self] success in
            defer { eDataFetched.fulfill() /* fullfill expectation on return */ }
            
            // assert post was removed
            self?.modelController.post(with: 1) { post in
                defer { ePostRemoved.fulfill() /* fullfill expectation on return */ }
                
                XCTAssertNil(post, "Post was removed (from queue)")
            }
        }
        
        // remove post while data is refreshing
        modelController.removePost(1) { [weak self] in
            // make sure it is still there
            self?.modelController.post(with: 1) { post in
                defer { ePostNotRemoved.fulfill() /* fullfill expectation on return */ }
                
                XCTAssertNotNil(post, "Post was NOT removed (but queued instead)")
            }
        }
        
        // remove post while
        
        wait(for: [eDataFetched, ePostNotRemoved, ePostRemoved], timeout: 1)
    }
    
    
    // MARK: - user(with:completion:)
    
    func test_user() {
        let e = XCTestExpectation(description: "Got an user from Core Data")
        modelController.user(with: 1) { user in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // assertions
            XCTAssertNotNil(user, "Found user")
            guard let user = user else { return }
            XCTAssertEqual(user.id, 1, "User have expected `id`")
            XCTAssertEqual(user.name, "User 1", "User have expected `title`")
            XCTAssertEqual(user.username, "user1", "User have expected `username`")
            XCTAssertEqual(user.email, "user1@email.com", "User have expected `email`")
        }
        wait(for: [e], timeout: 1)
    }
    
    func test_user_notFound() {
        let e = XCTestExpectation(description: "Got no user from Core Data")
        modelController.user(with: 99) { user in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // assertions
            XCTAssertNil(user, "User not found")
        }
        wait(for: [e], timeout: 1)
    }
    
    
    // MARK: - album(with:completion:)
    
    func test_album() {
        let e = XCTestExpectation(description: "Got a album from Core Data")
        modelController.album(with: 1) { album in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // assertions
            XCTAssertNotNil(album, "Found album")
            guard let album = album else { return }
            XCTAssertEqual(album.id, 1, "Album have expected `id`")
            XCTAssertEqual(album.title, "Album 1", "Album have expected `title`")
            XCTAssertEqual(album.photos.first?.id, 1, "Photo have expected author")
        }
        wait(for: [e], timeout: 1)
    }
    
    func test_album_notFound() {
        let e = XCTestExpectation(description: "Got no album from Core Data")
        modelController.album(with: 99) { album in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // assertions
            XCTAssertNil(album, "Album not found")
        }
        wait(for: [e], timeout: 1)
    }
    
    
    // MARK: - photo(with:completion:)
    
    func test_photo() {
        let e = XCTestExpectation(description: "Got a photo from Core Data")
        modelController.photo(with: 1) { photo in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // assertions
            XCTAssertNotNil(photo, "Found photo")
            guard let photo = photo else { return }
            XCTAssertEqual(photo.id, 1, "Photo have expected `id`")
            XCTAssertEqual(photo.title, "Photo 1", "Photo have expected `title`")
            XCTAssertNotNil(photo.url, "Photo have non-nill `url`")
            XCTAssertNotNil(photo.thumbnailUrl, "Photo have non-nill `thumbnailUrl`")
        }
        wait(for: [e], timeout: 1)
    }
    
    func test_photo_notFound() {
        let e = XCTestExpectation(description: "Got no photo from Core Data")
        modelController.photo(with: 999999) { photo in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // assertions
            XCTAssertNil(photo, "Photo not found")
        }
        wait(for: [e], timeout: 1)
    }
    
    
    // MARK: - refreshDataOnline()
    
    func test_refreshDataOnline() {
        // setup expected data
        mockSession.expectedData = { [weak self] url in
            if url.pathComponents.contains("posts") {
                return self?.fakeData.allPostsData
            }
            else if url.pathComponents.contains("users") {
                return self?.fakeData.allUsersData
            }
            else if url.pathComponents.contains("albums") {
                return self?.fakeData.allAlbumsData
            }
            else if url.pathComponents.contains("photos") {
                return self?.fakeData.allPhotosData
            }
            return nil
        }
        mockSession.expectedError = nil
        
        // remember previous data
        let oldPost1 = post(id: 1)
        let oldPost1Title = oldPost1?.title
        let oldPost1Body = oldPost1?.body
        let oldUser1 = user(id: 1)
        let oldUser1Name = oldUser1?.name
        let oldUser1Username = oldUser1?.username
        let oldUser1Email = oldUser1?.email
        let oldAlbum1 = album(id: 1)
        let oldAlbum1Title = oldAlbum1?.title
        let oldAlbum1PhotoCount = oldAlbum1?.photos?.allObjects.count ?? 0
        
        let e = XCTestExpectation(description: "Data received")
        modelController.refreshDataOnline() { [weak self] success in
            // assertions after merge
            XCTAssert(success, "Completion closure was called on success")
            
            // we're using the main context, bound to main thread
            DispatchQueue.main.sync {
                defer { e.fulfill() /* fullfill expectation on return */ }
                
                // post 1 was updated
                let post1 = self?.post(id: 1)
                XCTAssertNotEqual(oldPost1Title, post1?.title, "Post 1 title was updated")
                XCTAssertNotEqual(oldPost1Body, post1?.body, "Post 1 body was updated")

                // user 1 was updated
                let user1 = self?.user(id: 1)
                XCTAssertNotEqual(oldUser1Name, user1?.name, "User 1 name was updated")
                XCTAssertNotEqual(oldUser1Username, user1?.username, "User 1 username was updated")
                XCTAssertNotEqual(oldUser1Email, user1?.email, "User 1 email was updated")

                // user 999999 was removed
                let user999999 = self?.user(id: 999999)
                XCTAssertNil(user999999, "User id=999999 was removed")
            }
        }
        wait(for: [e], timeout: 1)
    }
    
    func test_refreshDataOnline_error() {
        // setup expected data
        mockSession.expectedData = nil
        mockSession.expectedError = { _ in APIError.httpError(code: 500) }
        
        let e = XCTestExpectation(description: "Error received")
        modelController.refreshDataOnline() { [weak self] success in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // assert we were called anyway
            XCTAssert(!success, "Completion closure was called on error")
        }
        wait(for: [e], timeout: 1)
    }
    
    
    // MARK: - addDelegate(_)
    
    func test_addDelegate() {
        let initialRegisteredCount = modelController.registeredDelegates().count
        
        // add delegate
        let delegate = ModelControllerTestsDelegate()
        modelController.addDelegate(delegate)
        
        // assert
        let registeredCount = modelController.registeredDelegates().count
        XCTAssertEqual(registeredCount, initialRegisteredCount + 1, "Delegate was added")
        
        // remove delegate
        modelController.removeDelegate(delegate)
    }
    
    
    // MARK: - removeDelegate(_)
    
    func test_removeDelegate() {
        // add delegate
        let delegate = ModelControllerTestsDelegate()
        modelController.addDelegate(delegate)
        
        let initialRegisteredCount = modelController.registeredDelegates().count
        
        // remove delegate
        modelController.removeDelegate(delegate)
        
        // assert
        let registeredCount = modelController.registeredDelegates().count
        XCTAssertEqual(registeredCount, initialRegisteredCount - 1, "Delegate was removed")
    }
    
    
    // MARK: - notifyDelegates(_)
    
    func test_notifyDelegates() {
        // add delegate
        let delegate = ModelControllerTestsDelegate()
        modelController.addDelegate(delegate)
        
        // setup expectations
        let eDataWillRefresh = XCTestExpectation(description: "Data will refresh")
        let eDataDidRefresh = XCTestExpectation(description: "Data did refresh")
        let ePostWasRemoved = XCTestExpectation(description: "Post was removed")
        delegate.dataWillRefreshClosure = {
            eDataWillRefresh.fulfill() // fullfill expectation
        }
        delegate.dataDidRefreshClosure = { _ in
            eDataDidRefresh.fulfill() // fullfill expectation
        }
        delegate.postWasRemovedClosure = {
            ePostWasRemoved.fulfill() // fullfill expectation
        }
        
        // postWasRemoved(postId:)
        modelController.removePost(1, completion: {})
        
        // dataWillRefresh() and dataDidRefresh()
        mockSession.expectedData = { _ in "[]".data(using: .utf8) }
        mockSession.expectedError = nil
        modelController.refreshDataOnline()
        
        wait(for: [eDataWillRefresh, eDataDidRefresh, ePostWasRemoved], timeout: 5)
        
        // remove delegate
        modelController.removeDelegate(delegate)
    }
    
}


// MARK: - Core Data helper methods (for asserting expected values)
extension ModelControllerTests {
    
    func post(id: Int64) -> ManagedPost? {
        var post: ManagedPost?
        dataController.mainManagedObjectContext.performAndWait {
            let request: NSFetchRequest<ManagedPost> = ManagedPost.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", id)
            request.includesPropertyValues = true
            post = try! dataController.mainManagedObjectContext.fetch(request).first
        }
        return post
    }
    
    func user(id: Int64) -> ManagedUser? {
        var user: ManagedUser?
        dataController.mainManagedObjectContext.performAndWait {
            let request: NSFetchRequest<ManagedUser> = ManagedUser.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", id)
            user = try! dataController.mainManagedObjectContext.fetch(request).first
        }
        return user
    }
    
    func album(id: Int64) -> ManagedAlbum? {
        var album: ManagedAlbum?
        dataController.mainManagedObjectContext.performAndWait {
            let request: NSFetchRequest<ManagedAlbum> = ManagedAlbum.fetchRequest()
            request.relationshipKeyPathsForPrefetching = ["photos"]
            request.predicate = NSPredicate(format: "id == %d", id)
            album = try! dataController.mainManagedObjectContext.fetch(request).first
        }
        return album
    }
    
}


// Class implementing the `ModelControllerDelegate`
class ModelControllerTestsDelegate: ModelControllerDelegate {
    var dataWillRefreshClosure: (() -> Void)?
    var dataDidRefreshClosure: ((Bool) -> Void)?
    var postWasRemovedClosure: (() -> Void)?
    
    func dataWillRefresh() {
        dataWillRefreshClosure?()
    }
    
    func dataDidRefresh(success: Bool) {
        dataDidRefreshClosure?(success)
    }
    
    func postWasRemoved(postId: Int64) {
        postWasRemovedClosure?()
    }
}
