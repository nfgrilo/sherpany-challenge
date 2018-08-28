//
//  APIController.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation

// Requirement #3: ✅ (fetch online data from REST API)

/// The REST API controller allows interaction (currently only fetching) with the JSON Placeholder API
class APIController {
    
    /// API request completion results.
    enum APIResult<T: APIResponse> {
        case success([T])
        case failure(Error)
    }
    
    /// API requests currently being executed.
    private var requests: [AnyObject] = []
    
    
    // MARK: - Fetch All Data
    
    /// Fetch all data from the API (posts, users, albums & photos).
    ///
    /// - Parameter completion: Completion closure called when response is received and parsed, or an error occurs.
    func fetchAllData(completion: @escaping (APIResult<AggregateResponse>) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        // variables that will hold fetched values
        var posts: [PostResponse]!
        var users: [UserResponse]!
        var albums: [AlbumResponse]!
        var photos: [PhotoResponse]!
        var errors: [Error] = []
        
        // fetch all posts
        dispatchGroup.enter()
        fetchPosts { result in
            switch result {
            case .success(let response):
                posts = response
            case .failure(let error):
                print("Error fetching posts: \(error)")
                errors.append(error)
            }
            dispatchGroup.leave()
        }
        
        // fetch all users
        dispatchGroup.enter()
        fetchUsers { result in
            switch result {
            case .success(let response):
                users = response
            case .failure(let error):
                print("Error fetching users: \(error)")
                errors.append(error)
            }
            dispatchGroup.leave()
        }
        
        // fetch all albums
        dispatchGroup.enter()
        fetchAlbums { result in
            switch result {
            case .success(let response):
                albums = response
            case .failure(let error):
                print("Error fetching albums: \(error)")
                errors.append(error)
            }
            dispatchGroup.leave()
        }
        
        // fetch all photos
        dispatchGroup.enter()
        fetchPhotos { result in
            switch result {
            case .success(let response):
                photos = response
            case .failure(let error):
                print("Error fetching photos: \(error)")
                errors.append(error)
            }
            dispatchGroup.leave()
        }
        
        // process all results
        dispatchGroup.notify(queue: DispatchQueue.global(qos: .background)) {
            guard errors.isEmpty else {
                completion(.failure( APIError.compoundErrors(errors: errors) ))
                return
            }
            let allData = AggregateResponse(posts: posts, users: users, albums: albums, photos: photos)
            completion(.success( [allData] ))
        }
    }
    
    
    // MARK: - Individual data fetching
    
    /// Fetch one or all posts from the API.
    ///
    /// - Parameters:
    ///   - postId: The optional post id.
    ///   - completion: Completion closure called when response is received and parsed, or an error occurs.
    func fetchPosts(postId: Int? = nil, completion: @escaping (APIResult<PostResponse>) -> Void) {
        // define API resource & request
        let resource = PostsAPIResource(postId: postId)
        let request = APIRequest(resource)
        
        // keep a strong ref to request
        requests.append(request)
        
        request.load { [weak self] (postResponse: [PostResponse]?) in
            // call completion
            guard let posts = postResponse else {
                completion(.failure( APIError.emptyResponse ))
                return
            }
            completion(.success(posts))

            // remove request reference so it can be deallocated
            if let requestIndex = self?.requests.index(where: { return ($0 as? APIRequest) == request }) {
                self?.requests.remove(at: requestIndex)
            }
        }
    }
    
    /// Fetch one or all users from the API.
    ///
    /// - Parameters:
    ///   - userId: The optional user id.
    ///   - completion: Completion closure called when response is received and parsed, or an error occurs.
    func fetchUsers(userId: Int? = nil, completion: @escaping (APIResult<UserResponse>) -> Void) {
        // define API resource & request
        let resource = UsersAPIResource(userId: userId)
        let request = APIRequest(resource)
        
        // keep a strong ref to request
        requests.append(request)
        
        request.load { [weak self] (userResponse: [UserResponse]?) in
            // call completion
            guard let users = userResponse else {
                completion(.failure( APIError.emptyResponse ))
                return
            }
            completion(.success(users))
            
            // remove request reference so it can be deallocated
            if let requestIndex = self?.requests.index(where: { return ($0 as? APIRequest) == request }) {
                self?.requests.remove(at: requestIndex)
            }
        }
    }
    
    /// Fetch one or all albums from the API.
    ///
    /// - Parameters:
    ///   - albumId: An optional album id, which will return a single album.
    ///   - userId: An optional user id, which will return this user's albums.
    ///   - completion: Completion closure called when response is received and parsed, or an error occurs.
    func fetchAlbums(albumId: Int? = nil, userId: Int? = nil, completion: @escaping (APIResult<AlbumResponse>) -> Void) {
        // make sure that both `albumId` and `userId` are specified (invalid)
        guard albumId == nil || userId == nil else {
            completion(.failure( APIError.invalidRequest(message: "Can't specify `albumId` and `userId` simultaneously") ))
            return
        }
        
        // define API resource & request
        let resource = AlbumsAPIResource(albumId: albumId, userId: userId)
        let request = APIRequest(resource)
        
        // keep a strong ref to request
        requests.append(request)
        
        request.load { [weak self] (albumResponse: [AlbumResponse]?) in
            // call completion
            guard let albums = albumResponse else {
                completion(.failure( APIError.emptyResponse ))
                return
            }
            completion(.success(albums))
            
            // remove request reference so it can be deallocated
            if let requestIndex = self?.requests.index(where: { return ($0 as? APIRequest) == request }) {
                self?.requests.remove(at: requestIndex)
            }
        }
    }
    
    /// Fetch one or all photos from the API.
    ///
    /// - Parameters:
    ///   - photId: An optional photo id, which will return a single photo.
    ///   - albumId: An optional album id, which will return all album's photos.
    ///   - completion: Completion closure called when response is received and parsed, or an error occurs.
    func fetchPhotos(photoId: Int? = nil, albumId: Int? = nil, completion: @escaping (APIResult<PhotoResponse>) -> Void) {
        // make sure that both `photoId` and `albumId` are specified (invalid)
        guard photoId == nil || albumId == nil else {
            completion(.failure( APIError.invalidRequest(message: "Can't specify `photoId` and `albumId` simultaneously") ))
            return
        }
        
        // define API resource & request
        let resource = PhotosAPIResource(photoId: photoId, albumId: albumId)
        let request = APIRequest(resource)
        
        // keep a strong ref to request
        requests.append(request)
        
        request.load { [weak self] (photoResponse: [PhotoResponse]?) in
            // call completion
            guard let photos = photoResponse else {
                completion(.failure( APIError.emptyResponse ))
                return
            }
            completion(.success(photos))
            
            // remove request reference so it can be deallocated
            if let requestIndex = self?.requests.index(where: { return ($0 as? APIRequest) == request }) {
                self?.requests.remove(at: requestIndex)
            }
        }
    }

}