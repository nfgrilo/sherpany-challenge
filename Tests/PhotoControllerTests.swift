//
//  PhotoControllerTests.swift
//  Tests
//
//  Created by Nuno Grilo on 29/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import XCTest
@testable import Sherpany_Posts

class PhotoControllerTests: XCTestCase {
    
    // MARK: - Setup
    
    var photoController: PhotoController!
    var fakeData: FakeData!
    var mockSession: URLSessionMock!
    
    override func setUp() {
        super.setUp()
        
        // initialize fake data
        fakeData = FakeData()
        
        // initialize mock URL session
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpMaximumConnectionsPerHost = 1
        mockSession = URLSessionMock(configuration: configuration)
        let noImage = fakeData.samplePhoto
        mockSession.expectedData = { url in
            return UIImagePNGRepresentation(noImage)
        }
        mockSession.expectedError = nil
        
        // initialize controller
        //  -> using mock session to avoid network hit
        //  -> using serial network serial (instead of concurrent);
        //     this allows priorities to be properly tested
        photoController = PhotoController(session: mockSession)
        photoController.networkQueue = DispatchQueue(label: "PhotoController Network Access", qos: .background)
    }
    
    override func tearDown() {
        super.tearDown()
        
        // clean up
        photoController = nil
        fakeData = nil
        mockSession = nil
    }
    
    
    // MARK: - photo(for:)
    
    func test_photo() {
        // assert not cached
        let noImage = photoController.photo(for: fakeData.samplePhotoURL)
        XCTAssertNil(noImage, "No cached photo found")
        
        let e = XCTestExpectation(description: "Downloaded and cached photo")
        photoController.fetchPhotos(from: [fakeData.samplePhotoURL], priority: .normal) { [weak self] url, image in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // assertions
            XCTAssertEqual(url, self?.fakeData.samplePhotoURL, "Downloaded requested URL")
            XCTAssertNotNil(image, "Image is not nil")
            
            // assert is cached
            let cachedImage = self?.photoController.photo(for: self?.fakeData.samplePhotoURL)
            XCTAssertNotNil(cachedImage, "Cached photo found")
        }
        wait(for: [e], timeout: 1)
    }
    
    // MARK: - fetchPhotos(from:priority:completion:)
    
    func test_fetchPhotos() {
        let e = XCTestExpectation(description: "Downloaded photo")
        let url1 = URL(string: "http://test/1")!
        photoController.fetchPhotos(from: [url1], priority: .normal) { [weak self] url, image in
            defer { e.fulfill() /* fullfill expectation on return */ }
            
            // assertions
            XCTAssertEqual(url, url1, "Downloaded requested URL")
            XCTAssertNotNil(image, "Image is not nil")
        }
        wait(for: [e], timeout: 1)
    }
    
    func test_fetchPhotos_noURLs() {
        let e = XCTestExpectation(description: "No photo downloaded")
        e.isInverted = true
        photoController.fetchPhotos(from: [], priority: .normal) { [weak self] url, image in
            defer { e.fulfill() /* fullfill expectation on return */ }
        }
        wait(for: [e], timeout: 1)
    }
    
    func test_fetchPhotos_priorities() {
        // URLs
        let url0 = URL(string: "http://test/0")!    // 6x to fill queue -> .normal
        let url1 = URL(string: "http://test/1")!    // |
        let url2 = URL(string: "http://test/2")!    // |-> .low
        let url3 = URL(string: "http://test/3")!    //  -> .high
        let url4 = URL(string: "http://test/4")!    //  -> .veryLow
        let url5 = URL(string: "http://test/5")!    //  -> .normal
        let url6 = URL(string: "http://test/6")!    //  -> .high
        
        // expectations (in order)
        let ePhotos0 = XCTestExpectation(description: "Initial buch of photos fetched")
        let ePhoto1 = XCTestExpectation(description: "Photo 1 fetched")
        let ePhoto2 = XCTestExpectation(description: "Photo 2 fetched")
        let ePhoto3 = XCTestExpectation(description: "Photo 3 fetched")
        let ePhoto4 = XCTestExpectation(description: "Photo 4 fetched")
        let ePhoto5 = XCTestExpectation(description: "Photo 5 fetched")
        let ePhoto6 = XCTestExpectation(description: "Photo 6 fetched")
        let expectations = [ePhoto3, ePhoto5, ePhoto6, ePhoto2, ePhoto1, ePhoto4]
        
        // url0 - .normal (fill queue)
        photoController.fetchPhotos(from: [url0, url0, url0, url0, url0, url0], priority: .normal) { url, image in
            //print(ePhotos0.description)
            ePhotos0.fulfill() // this will be called more than once - not relevant here, no problem
        }
        // url1, url2 - .low
        photoController.fetchPhotos(from: [url1, url2], priority: .low) { url, image in
            if url == url1 { /*print(ePhoto1.description);*/ ePhoto1.fulfill() }
            else if url == url2 { /*print(ePhoto2.description);*/ ePhoto2.fulfill() }
        }
        // url3 - .high
        photoController.fetchPhotos(from: [url3], priority: .high) { url, image in
            //print(ePhoto3.description)
            ePhoto3.fulfill()
        }
        // url4 - .veryLow
        photoController.fetchPhotos(from: [url4], priority: .veryLow) { url, image in
            //print(ePhoto4.description)
            ePhoto4.fulfill()
        }
        // url5 - .normal
        photoController.fetchPhotos(from: [url5], priority: .normal) { url, image in
            //print(ePhoto5.description)
            ePhoto5.fulfill()
        }
        // url6 - .high
        photoController.fetchPhotos(from: [url6], priority: .high) { url, image in
            //print(ePhoto6.description)
            ePhoto6.fulfill()
        }
        
        // wait for expectations to fulfill in order
        wait(for: expectations, timeout: 1, enforceOrder: true)
        wait(for: [ePhotos0], timeout: 1)
    }
    
    // MARK: - slowdownPhotoFetches(urls:)
    
    func test_slowdownPhotoFetches() {
        // URLs
        let url0 = URL(string: "http://test/0")!
        let url1 = URL(string: "http://test/1")!
        let url2 = URL(string: "http://test/2")!
        let url3 = URL(string: "http://test/3")!
        let url4 = URL(string: "http://test/4")!
        let url5 = URL(string: "http://test/5")!
        let url6 = URL(string: "http://test/6")!
        
        // expectations (in order)
        let ePhoto0 = XCTestExpectation(description: "Photo 0 fetched")
        let ePhoto1 = XCTestExpectation(description: "Photo 1 fetched")
        let ePhoto2 = XCTestExpectation(description: "Photo 2 fetched")
        let ePhoto3 = XCTestExpectation(description: "Photo 3 fetched")
        let ePhoto4 = XCTestExpectation(description: "Photo 4 fetched")
        let ePhoto5 = XCTestExpectation(description: "Photo 5 fetched")
        let ePhoto6 = XCTestExpectation(description: "Photo 6 fetched")
        let expectations = [ePhoto6, ePhoto4, ePhoto2, ePhoto0, ePhoto5, ePhoto3, ePhoto1]
        
        // url0 - .normal (fill queue)
        photoController.fetchPhotos(from: [url0, url1, url2, url3, url4, url5, url6], priority: .normal) { url, image in
            var expectation: XCTestExpectation?
            switch url {
                case url0: expectation = ePhoto0
                case url1: expectation = ePhoto1
                case url2: expectation = ePhoto2
                case url3: expectation = ePhoto3
                case url4: expectation = ePhoto4
                case url5: expectation = ePhoto5
                case url6: expectation = ePhoto6
                default: break
            }
            if let expectation = expectation {
                //print(expectation.description)
                expectation.fulfill()
            }
        }
        
        // slowdown some
        photoController.slowdownPhotoFetches(urls: [url1, url3, url5])
        
        // wait for expectations to fulfill in order
        wait(for: expectations, timeout: 1, enforceOrder: true)
    }
    
    // MARK: - cancelAllPhotoFetchs()
    
    func test_cancelAllPhotoFetchs() {
        // URLs
        let url0 = URL(string: "http://test/0")!
        let url1 = URL(string: "http://test/1")!
        let url2 = URL(string: "http://test/2")!
        
        // expectations (in order)
        let ePhoto0 = XCTestExpectation(description: "Photo 0 fetched")
        ePhoto0.isInverted = true
        let ePhoto1 = XCTestExpectation(description: "Photo 1 fetched")
        ePhoto1.isInverted = true
        let ePhoto2 = XCTestExpectation(description: "Photo 2 fetched")
        ePhoto2.isInverted = true
        let expectations = [ePhoto0, ePhoto1, ePhoto2]
        
        // url0 - .normal (fill queue)
        photoController.fetchPhotos(from: [url0, url1, url2], priority: .normal) { url, image in
            var expectation: XCTestExpectation?
            switch url {
                case url0: expectation = ePhoto0
                case url1: expectation = ePhoto1
                case url2: expectation = ePhoto2
                default: break
            }
            if let expectation = expectation {
                expectation.fulfill()
            }
        }
        
        // cancel all fetches
        photoController.cancelAllPhotoFetchs()
        
        // wait for expectations to fulfill in order
        wait(for: expectations, timeout: 1)
    }
    
}
