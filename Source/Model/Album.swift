//
//  Album.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation
import CoreData

struct Album: Equatable {
    let id: Int64
    let title: String
    
    let photos: [Photo]
}

extension Album {
    init(managedAlbum: ManagedAlbum) {
        // PS: both `String` attributes are defined as non-optionals, which is not being respected on the generated managed object classes.
        
        // attributes
        id = managedAlbum.id
        title = managedAlbum.title ?? ""
        
        // relationship: ManagedAlbum -> 1:N -> ManagedPhoto
        var photoList: [Photo] = []
        if let managedPhotos = managedAlbum.photos?.allObjects as? [ManagedPhoto] {
            managedPhotos.forEach {
                photoList.append(Photo(managedPhoto: $0))
            }
        }
        photos = photoList
    }
}
