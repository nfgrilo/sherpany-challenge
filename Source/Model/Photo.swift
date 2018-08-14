//
//  Photo.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation
import CoreData

struct Photo: Equatable {
    let id: Int64
    let title: String
    let url: URL?
    let thumbnailUrl: URL?
}

extension Photo {
    init(managedPhoto: ManagedPhoto) {
        // PS: `title` `String` attribute is defined as non-optional, which is not being respected on the generated managed object class.
        
        // attributes
        id = managedPhoto.id
        title = managedPhoto.title ?? ""
        url = managedPhoto.url
        thumbnailUrl = managedPhoto.thumbnailUrl
    }
}
