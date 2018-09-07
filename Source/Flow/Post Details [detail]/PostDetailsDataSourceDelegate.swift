//
//  PostDetailsDataSourceDelegate.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 08/09/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation

protocol PostDetailsDataSourceDelegate: class {
    /// Invoked when a photo was tapped.
    ///
    /// - Parameter photo: The tapped photo.
    func photoWasTapped(_ photo: Photo)
}
