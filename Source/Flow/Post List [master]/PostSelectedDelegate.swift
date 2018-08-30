//
//  PostSelectedDelegate.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 16/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation

protocol PostSelectedDelegate: class {
    /// Informs delegate that a post has been selected.
    ///
    /// - Parameter postId: The ID of selected post.
    func postSelected(postId: Int64?)
}
