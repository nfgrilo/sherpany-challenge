//
//  MockURLSession.swift
//  Tests
//
//  Created by Nuno Grilo on 28/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation

class URLSessionMock: URLSession {

    /// Data to be returned on completion handler.
    var expectedData: ((URL) -> Data?)?
    
    /// Error to be returned on completion handler.
    var expectedError: ((URL) -> Error?)?
    
    /// URL session configuration.
    /// Overriding variable as can't access `super.init(configuration:)`.
    override var configuration: URLSessionConfiguration {
        get {
            return self.mockConfiguration ?? self.configuration
        }
    }
    
    /// Custom URL configuration (optional)
    private var mockConfiguration: URLSessionConfiguration?

    override init() {
        super.init()
    }

    init(configuration: URLSessionConfiguration) {
        super.init()
        self.mockConfiguration = configuration
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let data = expectedData?(url)
        let error = expectedError?(url)
        return MockURLSessionDataTask() {
            completionHandler(data, nil, error)
        }
    }
    
}

class MockURLSessionDataTask: URLSessionDataTask {
    
    /// Closure to be called after calling `resume()`.
    private let closure: () -> Void
    
    /// Initialize data task.
    ///
    /// - Parameter closure: Closure to be called on `resume()`.
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
    
}
