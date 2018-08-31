//
//  ModelControllerDelegate.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 16/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation

/// `ModelController` delegate protocol.
protocol ModelControllerDelegate: class {
    
    /// Called whenever data is about to be updated from REST API & merged into Core Data.
    func dataWillRefresh()
    
    /// Called whenever data is updated from REST API & merged into Core Data.
    func dataDidRefresh(success: Bool)
    
    /// Called when a post was removed.
    ///
    /// - Parameter postId: The post id.
    func postWasRemoved(postId: Int64)
    
}
