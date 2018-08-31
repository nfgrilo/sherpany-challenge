//
//  APIResource.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation


// MARK: - API Resource Protocol

protocol APIResource {
    associatedtype Model: APIResponse, Codable
    
    /// HTTP method.
    var method: String { get }
    
    /// API resource URL.
    var url: URL? { get }
    
    /// Parse a response returned by the Rest API.
    func parseResponse(_ data: Data) throws -> [Model]?
    
}

extension APIResource {
    func parseResponse(_ data: Data) throws -> [Model]? {
        // decode response
        let decoder = JSONDecoder()
        do {
            // -> a) list of values?
            return try decoder.decode(Array<Model>.self, from: data)
        } catch {
            do {
                // -> or b) single value?
                return [try decoder.decode(Model.self, from: data)]
            } catch {
                throw error
            }
        }
    }
}



// MARK: - API Resource Definitions

struct PostsAPIResource: APIResource {
    typealias Model = PostResponse
    
    /// An optional post id.
    var postId: Int?
    
    let method: String = "GET"
    
    var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "jsonplaceholder.typicode.com"
        urlComponents.path = "/posts"
        if let postId = self.postId {
            urlComponents.path += "/\(postId)"
        }
        return urlComponents.url
    }
}

struct UsersAPIResource: APIResource {
    typealias Model = UserResponse
    
    /// An optional user id.
    var userId: Int?
    
    let method: String = "GET"
    
    var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "jsonplaceholder.typicode.com"
        urlComponents.path = "/users"
        if let userId = self.userId {
            urlComponents.path += "/\(userId)"
        }
        return urlComponents.url
    }
}

struct AlbumsAPIResource: APIResource {
    typealias Model = AlbumResponse
    
    /// An optional album id.
    var albumId: Int?
    
    /// An optional user id.
    var userId: Int?
    
    let method: String = "GET"
    
    var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "jsonplaceholder.typicode.com"
        if let userId = self.userId {
            // some user's albums
            urlComponents.path = "/users/\(userId)/albums"
        }
        else {
            urlComponents.path = "/albums"
            if let albumId = self.albumId {
                // a specific album
                urlComponents.path += "/\(albumId)"
            }
        }
        return urlComponents.url
    }
}

struct PhotosAPIResource: APIResource {
    typealias Model = PhotoResponse
    
    /// An optional photo id.
    var photoId: Int?
    
    /// An optional album id.
    var albumId: Int?
    
    let method: String = "GET"
    
    var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "jsonplaceholder.typicode.com"
        
        if let albumId = self.albumId {
            // some album's photos
            urlComponents.path = "/albums/\(albumId)/photos"
        }
        else {
            urlComponents.path = "/photos"
            if let photoId = self.photoId {
                // a specific photo
                urlComponents.path += "/\(photoId)"
            }
        }
        return urlComponents.url
    }
}
