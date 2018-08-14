//
//  User.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation
import CoreData

struct User: Equatable {
    let id: Int64
    let name: String
    let username: String
    let email: String
    
    let albums: [Album]
}

extension User {
    init(managedUser: ManagedUser) {
        // PS: both `String` attributes are defined as non-optionals, which is not being respected on the generated managed object classes.
        
        // attributes
        id = managedUser.id
        name = managedUser.name ?? ""
        username = managedUser.username ?? ""
        email = managedUser.email ?? ""
        
        // relationship: ManagedUser -> 1:N -> ManagedAlbum
        var albumList: [Album] = []
        if let managedAlbums = managedUser.albums?.allObjects as? [ManagedAlbum] {
            managedAlbums.forEach {
                albumList.append(Album(managedAlbum: $0))
            }
        }
        albums = albumList
    }
}
