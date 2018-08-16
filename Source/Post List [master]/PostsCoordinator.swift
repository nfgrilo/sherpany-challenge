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
    
    /// Weak reference to presented view controller.
    ///
    /// A strong reference is already made when vc is presented (added to vc hierarchy).
    private weak var viewController: PostsViewController?
    
    /// Model controller.
    private let modelController: ModelController
    
    /// Creates a new coordinator.
    ///
    /// - Parameter navigationController: The root view controller "BOSSed" by this coordinator.
    init(navigationController: UINavigationController, modelController: ModelController) {
        self.navigationController = navigationController
        self.modelController = modelController
    }
    
    /// Posts data source.
    private var dataSource: PostsDataSource?
    
    /// Take control!
    func start() {
        // create & setup vc
        guard let postsVC = PostsViewController.instantiate() else { return }
        postsVC.coordinator = self
        self.viewController = postsVC
        
        // table view
        dataSource = PostsDataSource(modelController: modelController)
        postsVC.tableView.dataSource = dataSource
        dataSource?.refreshPostList(in: postsVC.tableView)
        
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

