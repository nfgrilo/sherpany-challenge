//
//  APIRequest.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation


// MARK: - Network request protocol

protocol NetworkRequest: class {
    associatedtype Model
    
    /// Load a response from the Rest API.
    func load(session: URLSession, completion: @escaping ([Model]?) -> Void)
    
    /// Parse a response returned by the Rest API.
    func parseResponse(_ data: Data) -> [Model]?
}

extension NetworkRequest {
    func load(_ url: URL, session: URLSession, completion: @escaping ([Model]?) -> Void) {
        let task = session.dataTask(with: url, completionHandler: { [weak self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(self?.parseResponse(data))
        })
        task.resume()
    }
}


// MARK: - API request

class APIRequest<Resource: APIResource> {
    let resource: Resource
    let uuid: String
    
    init(_ resource: Resource) {
        self.resource = resource
        self.uuid = UUID().uuidString
    }
}

extension APIRequest: NetworkRequest {
    func parseResponse(_ data: Data) -> [Resource.Model]? {
        do {
            return try resource.parseResponse(data)
        } catch {
            print(error)
            return nil
        }
    }
    
    func load(session: URLSession, completion: @escaping ([Resource.Model]?) -> Void) {
        guard let url = resource.url else {
            completion(nil)
            return
        }
        load(url, session: session, completion: completion)
    }
}

extension APIRequest: Equatable, Hashable {
    var hashValue: Int {
        return uuid.hashValue
    }
    
    static func == (lhs: APIRequest<Resource>, rhs: APIRequest<Resource>) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
