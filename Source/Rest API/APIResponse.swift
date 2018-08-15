//
//  APIResponse.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation

protocol APIResponse { }

struct PostResponse: Codable, APIResponse {
    /// Post ID.
    let id: Int
    
    /// Post user ID.
    let userId: Int
    
    /// Post title.
    let title: String
    
    /// Post body.
    let body: String
}

struct UserResponse: Codable, APIResponse {
    /// User ID.
    let id: Int
    
    /// User full name.
    let name: String
    
    /// User username.
    let username: String
    
    /// User email.
    let email: String
    
    /// Note: The `User` struct has additional fields which are (currently) not used within the app.
}

struct AlbumResponse: Codable, APIResponse {
    /// Album ID.
    let id: Int
    
    /// Album author user ID.
    let userId: Int
    
    /// Album title.
    let title: String
}

struct PhotoResponse: Codable, APIResponse {
    /// Photo ID.
    let id: Int
    
    /// Album ID the photo belongs to.
    let albumId: Int
    
    /// Photo title.
    let title: String
    
    /// Photo URL.
    let url: URL
    
    /// Photo thumbnail URL.
    let thumbnailUrl: URL
}

struct AggregateResponse: Codable, APIResponse {
    let posts: [PostResponse]
    let users: [UserResponse]
    let albums: [AlbumResponse]
    let photos: [PhotoResponse]
}
