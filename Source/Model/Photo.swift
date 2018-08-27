//
//  Photo.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation
import CoreData

/// An immutable and thread-safe `Photo` model based on the correspondent Core Data managed object (`ManagedPhoto`).
struct Photo: Equatable {
    let id: Int64
    let title: String?
    let url: URL?
    let thumbnailUrl: URL?
}

extension Photo {
    /// Intialize model from the correspondent Core Data managed object.
    ///
    /// - Parameter managedPhoto: The CoreData managed object
    init(managedPhoto: ManagedPhoto) {
        // attributes
        id = managedPhoto.id
        title = managedPhoto.title?.firstLetterCapitalized
        url = managedPhoto.url
        thumbnailUrl = managedPhoto.thumbnailUrl
    }
}
