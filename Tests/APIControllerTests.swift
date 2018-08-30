//
//  APIControllerTests.swift
//  Tests
//
//  Created by Nuno Grilo on 28/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import XCTest
@testable import Sherpany_Posts

class APIControllerTests: XCTestCase {
    
    // MARK: - Setup
    
    var apiController: APIController!
    var mockSession: URLSessionMock!
    var fakeData: FakeData!
    
    override func setUp() {
        super.setUp()
        
        // initialize fake data
        fakeData = FakeData()
        
        // initialize mocks
        mockSession = URLSessionMock()
        
        // initialize controller
        apiController = APIController(session: mockSession)
    }
    
    override func tearDown() {
        super.tearDown()
        
        // clean up
        mockSession = nil
        apiController = nil
        fakeData = nil
    }
    
    
    // MARK: - fetchAllData()
    
    func test_fetchAllData() {
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
        
        let e = XCTestExpectation(description: "Response received")
        apiController.fetchAllData { result in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // get response object
            var responseObject: [Any]? = nil
            if case let .success(response) = result {
                responseObject = response
            }
            
            // assertions
            XCTAssert(responseObject?.first is AggregateResponse, "Response is a non-empty array with a single `AggregateResponse`")
            XCTAssert(responseObject?.count ?? 0 == 1, "Response is a non-empty array")
            if let aggregateResponse = responseObject?.first as? AggregateResponse {
                XCTAssert(aggregateResponse.posts.count > 0, "Response contain posts")
                XCTAssert(aggregateResponse.users.count > 0, "Response contain users")
                XCTAssert(aggregateResponse.albums.count > 0, "Response contain albums")
                XCTAssert(aggregateResponse.photos.count > 0, "Response contain photos")
            }
        }
        wait(for: [e], timeout: 1)
    }
    
    func test_fetchAllData_error() {
        // setup expected data
        mockSession.expectedData = { _ in "[{id: 9999}]".data(using: .utf8) }
        mockSession.expectedError = nil
        
        let e = XCTestExpectation(description: "Response received")
        apiController.fetchAllData { result in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // get response object
            var responseError: Error? = nil
            if case let .failure(error) = result {
                responseError = error
            }
            
            // assertions
            XCTAssert(responseError != nil, "Response contains errors")
        }
        wait(for: [e], timeout: 1)
    }
    
    func test_fetchAllData_error2() {
        // setup expected data
        mockSession.expectedData = nil
        mockSession.expectedError = { _ in APIError.emptyResponse }
        
        let e = XCTestExpectation(description: "Response received")
        apiController.fetchAllData { result in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // get response object
            var responseError: Error? = nil
            if case let .failure(error) = result {
                responseError = error
            }
            
            // assertions
            XCTAssert(responseError != nil, "Response contains errors")
            XCTAssert(responseError != nil, "Response contains errors")
        }
        wait(for: [e], timeout: 1)
    }
    
    
    // MARK: - fetchPosts()
    
    func test_fetchPosts_all() {
        // setup expected data
        mockSession.expectedData = { [weak self] _ in self?.fakeData.allPostsData }
        mockSession.expectedError = nil
        
        let e = XCTestExpectation(description: "Response received")
        apiController.fetchPosts { result in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // get response object
            var responseObject: [Any]? = nil
            if case let .success(response) = result {
                responseObject = response
            }
            
            // assertions
            XCTAssert(responseObject is [PostResponse], "Response is an array of `PostResponse`")
            XCTAssert(responseObject?.count ?? 0 > 0, "Response is a non-empty array")
        }
        wait(for: [e], timeout: 1)
    }
    
    func test_fetchPosts_one() {
        // setup expected data
        mockSession.expectedData = { [weak self] _ in self?.fakeData.onePostData }
        mockSession.expectedError = nil
        
        let e = XCTestExpectation(description: "Response received")
        apiController.fetchPosts(postId: 1) { result in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // get response object
            var responseObject: [Any]? = nil
            if case let .success(response) = result {
                responseObject = response
            }
            
            // assertions
            XCTAssert(responseObject is [PostResponse], "Response is an array of `PostResponse`")
            XCTAssert(responseObject?.count ?? 0 == 1, "Response has exactly one object")
        }
        wait(for: [e], timeout: 1)
    }
    
    
    // MARK: - fetchUsers()
    
    func test_fetchUsers_all() {
        // setup expected data
        mockSession.expectedData = { [weak self] _ in self?.fakeData.allUsersData }
        mockSession.expectedError = nil
        
        let e = XCTestExpectation(description: "Response received")
        apiController.fetchUsers { result in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // get response object
            var responseObject: [Any]? = nil
            if case let .success(response) = result {
                responseObject = response
            }
            
            // assertions
            XCTAssert(responseObject is [UserResponse], "Response is an array of `UserResponse`")
            XCTAssert(responseObject?.count ?? 0 > 0, "Response is a non-empty array")
        }
        wait(for: [e], timeout: 1)
    }
    
    func test_fetchUsers_one() {
        // setup expected data
        mockSession.expectedData = { [weak self] _ in self?.fakeData.oneUserData }
        mockSession.expectedError = nil
        
        let e = XCTestExpectation(description: "Response received")
        apiController.fetchUsers(userId: 1) { result in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // get response object
            var responseObject: [Any]? = nil
            if case let .success(response) = result {
                responseObject = response
            }
            
            // assertions
            XCTAssert(responseObject is [UserResponse], "Response is an array of `UserResponse`")
            XCTAssert(responseObject?.count ?? 0 == 1, "Response has exactly one object")
        }
        wait(for: [e], timeout: 1)
    }
    
    
    // MARK: - fetchAlbums()
    
    func test_fetchAlbums_all() {
        // setup expected data
        mockSession.expectedData = { [weak self] _ in self?.fakeData.allAlbumsData }
        mockSession.expectedError = nil
        
        let e = XCTestExpectation(description: "Response received")
        apiController.fetchAlbums { result in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // get response object
            var responseObject: [Any]? = nil
            if case let .success(response) = result {
                responseObject = response
            }
            
            // assertions
            XCTAssert(responseObject is [AlbumResponse], "Response is an array of `AlbumResponse`")
            XCTAssert(responseObject?.count ?? 0 > 0, "Response is a non-empty array")
        }
        wait(for: [e], timeout: 1)
    }
    
    func test_fetchAlbums_one() {
        // setup expected data
        mockSession.expectedData = { [weak self] _ in self?.fakeData.oneAlbumData }
        mockSession.expectedError = nil
        
        let e = XCTestExpectation(description: "Response received")
        apiController.fetchAlbums(albumId: 1) { result in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // get response object
            var responseObject: [Any]? = nil
            if case let .success(response) = result {
                responseObject = response
            }
            
            // assertions
            XCTAssert(responseObject is [AlbumResponse], "Response is an array of `AlbumResponse`")
            XCTAssert(responseObject?.count ?? 0 == 1, "Response has exactly one object")
        }
        wait(for: [e], timeout: 1)
    }
    
    
    // MARK: - fetchPhotos()
    
    func test_fetchPhotos_all() {
        // setup expected data
        mockSession.expectedData = { [weak self] _ in self?.fakeData.allPhotosData }
        mockSession.expectedError = nil
        
        let e = XCTestExpectation(description: "Response received")
        apiController.fetchPhotos { result in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // get response object
            var responseObject: [Any]? = nil
            if case let .success(response) = result {
                responseObject = response
            }
            
            // assertions
            XCTAssert(responseObject is [PhotoResponse], "Response is an array of `PhotoResponse`")
            XCTAssert(responseObject?.count ?? 0 > 0, "Response is a non-empty array")
        }
        wait(for: [e], timeout: 1)
    }
    
    func test_fetchPhotos_one() {
        // setup expected data
        mockSession.expectedData = { [weak self] _ in self?.fakeData.onePhotoData }
        mockSession.expectedError = nil
        
        let e = XCTestExpectation(description: "Response received")
        apiController.fetchPhotos(photoId: 1) { result in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // get response object
            var responseObject: [Any]? = nil
            if case let .success(response) = result {
                responseObject = response
            }
            
            // assertions
            XCTAssert(responseObject is [PhotoResponse], "Response is an array of `PhotoResponse`")
            XCTAssert(responseObject?.count ?? 0 == 1, "Response has exactly one object")
        }
        wait(for: [e], timeout: 1)
    }
    
}
