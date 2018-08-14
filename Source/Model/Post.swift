//
//  Post.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation
import CoreData

struct Post: Equatable {
    let id: Int64
    let title: String
    let body: String
    
    let user: User?
}

extension Post {
    init(managedPost: ManagedPost) {
        // PS: both `String` attributes are defined as non-optionals, which is not being respected on the generated managed object classes.
        
        // attributes
        id = managedPost.id
        title = managedPost.title ?? ""
        body = managedPost.body ?? ""
        
        // relationship: ManagedPost -> N:1 -> ManagedUser
        if let managedUser = managedPost.user {
            user = User(managedUser: managedUser)
        }
        else {
            user = nil
        }
    }
}
