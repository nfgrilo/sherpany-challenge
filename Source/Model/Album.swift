//
//  Album.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation
import CoreData

/// An immutable and thread-safe `Album` model based on the correspondent Core Data managed object (`ManagedAlbum`).
struct Album: Equatable {
    let id: Int64
    let title: String?
    
    let photos: [Photo]
}

extension Album {
    /// Intialize model from the correspondent Core Data managed object.
    ///
    /// - Parameter managedAlbum: The CoreData managed object
    init(managedAlbum: ManagedAlbum) {
        // attributes
        id = managedAlbum.id
        title = managedAlbum.title ?? ""
        
        // relationship: ManagedAlbum -> 1:N -> ManagedPhoto
        var photoList: [Photo] = []
        if let managedPhotos = managedAlbum.photos?.allObjects as? [ManagedPhoto] {
            managedPhotos.forEach {
                photoList.append(Photo(managedPhoto: $0))
            }
            photoList.sort { return $0.id < $1.id }
        }
        photos = photoList
    }
}
