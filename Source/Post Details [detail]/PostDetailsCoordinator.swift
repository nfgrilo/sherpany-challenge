//
//  PostDetailsCoordinator.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostDetailsCoordinator: Coordinator {
    /// Child coordinators.
    var childCoordinators: [Coordinator] = []
    
    /// The navigation view controller currently being used to present view controllers.
    var navigationController: UINavigationController
    
    /// Weak reference to presented view controller.
    ///
    /// A strong reference is already made when vc is presented (added to vc hierarchy).
    private weak var viewController: PostDetailsViewController?
    
    /// Model controller.
    private let modelController: ModelController
    
    
    /// Creates a coordinator.
    ///
    /// - Parameter navigationController: The root view controller "BOSSed" by this coordinator.
    init(navigationController: UINavigationController, modelController: ModelController) {
        self.navigationController = navigationController
        self.modelController = modelController
    }
    
    /// Take control!
    func start() {
        // create & setup vc
        guard let postDetailsVC = PostDetailsViewController.instantiate() else { return }
        postDetailsVC.coordinator = self
        viewController = postDetailsVC
        
        // present it
        navigationController.pushViewController(postDetailsVC, animated: false)
        navigationController.topViewController?.title = "Challenge Accepted!" // Requirement #1: ✅
    }
}


// MARK: - Post selection delegate

extension PostDetailsCoordinator: PostSelectedDelegate {
    // Requirement #9: ✅
    func postSelected(postId: Int64?) {
        // selection cleared out?
        guard let postId = postId else {
            viewController?.post = nil
            return
        }
        
        // get post from Core Data
        modelController.post(with: postId, completion: { [weak self] post in
            self?.viewController?.post = post
        })
    }
}
