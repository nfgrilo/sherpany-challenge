//
//  PostsDataSourceDelegate.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 07/09/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation

protocol PostsDataSourceDelegate: class {
    /// Invoked when a post has been selected.
    ///
    /// - Parameter post: The selected post.
    func postWasSelected(_ post: Post?)
    
    /// Invoked when a post has been deleted.
    ///
    /// - Parameter post: The deleted post.
    func postWasDeleted(_ post: Post)
    
    /// Invoked when the search text feedback did change.
    ///
    /// - Parameter searchFeedback: The current search feedback.
    func searchFeedbackDidChange(_ searchFeedback: String?)
}
