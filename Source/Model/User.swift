//
//  User.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation
import CoreData

/// An immutable and thread-safe `User` model based on the correspondent Core Data managed object (`ManagedUser`).
struct User: Equatable {
    let id: Int64
    let name: String?
    let username: String?
    let email: String?
    
    let albums: [Album]
}

extension User {
    /// Intialize model from the correspondent Core Data managed object.
    ///
    /// - Parameters:
    ///   - managedUser: The CoreData managed object
    ///   - fetchAlbums: Whether to fetch the `albums` relationship upon initialization. This will also fetch the `ManagedAlbum.photos` relationship.
    init(managedUser: ManagedUser, fetchAlbums: Bool = false) {
        // attributes
        id = managedUser.id
        name = managedUser.name
        username = managedUser.username
        email = managedUser.email
        
        // relationship: ManagedUser -> 1:N -> ManagedAlbum
        var albumList: [Album] = []
        if fetchAlbums,
            let managedAlbums = managedUser.albums?.allObjects as? [ManagedAlbum] {
            managedAlbums.forEach {
                albumList.append(Album(managedAlbum: $0))
            }
        }
        albums = albumList
    }
}
