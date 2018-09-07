//
//  PostsCoordinatorDelegate.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 16/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation

protocol PostsCoordinatorDelegate: class {
    /// Invoked when a post has been selected.
    ///
    /// - Parameter postId: The ID of selected post.
    func postWasSelected(postId: Int64?)
}
