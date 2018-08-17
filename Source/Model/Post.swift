//
//  Post.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation
import CoreData

/// An immutable and thread-safe `Post` model based on the correspondent Core Data managed object (`ManagedPost`).
struct Post: Equatable {
    let id: Int64
    let title: String?
    let body: String?
    
    let user: User?
}

extension Post {
    /// Intialize model from the correspondent Core Data managed object.
    ///
    /// - Parameters:
    ///   - managedPost: The CoreData managed object
    ///   - fetchUserAlbums: Whether to fetch the `user.albums` & `user.albums.photos` relationships upon initialization.
    init(managedPost: ManagedPost, fetchUserAlbums: Bool = false) {
        // attributes
        id = managedPost.id
        title = managedPost.title
        body = managedPost.body
        
        // relationship: ManagedPost -> N:1 -> ManagedUser
        if let managedUser = managedPost.user {
            user = User(managedUser: managedUser, fetchAlbums: fetchUserAlbums)
        }
        else {
            user = nil
        }
    }
}
