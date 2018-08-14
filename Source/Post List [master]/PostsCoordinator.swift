//
//  PostsCoordinator.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostsCoordinator: Coordinator {
    /// The navigation view controller currently being used to present view controllers.
    var navigationController: UINavigationController
    
    /// Post selection delegate.
    weak var postSelectedDelegate: PostSelectedDelegate?
    
    /// Creates a new coordinator.
    ///
    /// - Parameter navigationController: The root view controller "BOSSed" by this coordinator.
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    /// Posts data source.
    private var dataSource: PostsDataSource?
    
    /// Take control!
    func start() {
        // create & setup vc
        guard let postsVC = PostsViewController.instantiate() else { return }
        postsVC.coordinator = self
        
        // table view
        dataSource = PostsDataSource()
        postsVC.tableView.dataSource = dataSource
        
        // present it
        navigationController.pushViewController(postsVC, animated: false)
        navigationController.topViewController?.title = nil
    }
}


protocol PostSelectedDelegate: class {
    /// Informs delegate that a post has been selected.
    ///
    /// - Parameter id: The ID of selected post.
    func postSelected(id: Int)
}

