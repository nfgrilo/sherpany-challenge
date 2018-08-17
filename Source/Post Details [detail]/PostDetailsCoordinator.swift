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
    
    /// Post details view controller (strong ref: will be in and out of view hierarchy).
    private var postDetailsViewController: PostDetailsViewController?
    
    /// Empty view controller (strong ref: will be in and out of view hierarchy).
    private var noPostDetailsViewController: NoPostDetailsViewController?
    
    /// Model controller.
    private let modelController: ModelController
    
    /// Posts data source.
    private var dataSource: PostDetailsDataSource?
    
    /// Post details coordinator states.
    ///
    /// - noSelection: No post selected.
    /// - selected: Some post selected.
    enum State {
        case noSelection
        case selected(Post)
    }
    
    /// Post details coordinator state.
    private var state: State = .noSelection {
        didSet {
            switch state {
                
            /// no post selected
            case .noSelection:
                guard let viewController = noPostDetailsViewController else {
                    break
                }
                // -> present "no post" VC
                DispatchQueue.main.async { [weak self] in
                    if self?.navigationController.topViewController != viewController {
                        self?.navigationController.viewControllers = [viewController]
                    }
                }
                
            // some post selected
            case .selected(let post):
                guard let viewController = postDetailsViewController else {
                    break
                }
                // -> present post details VC
                dataSource?.post = post
                DispatchQueue.main.async { [weak self] in
                    if self?.navigationController.topViewController != viewController {
                        self?.navigationController.viewControllers = [viewController]
                    }
                    self?.postDetailsViewController?.tableView.reloadData()
                }
            }
            
        }
    }
    
    
    /// Creates a coordinator.
    ///
    /// - Parameter navigationController: The root view controller "BOSSed" by this coordinator.
    init(navigationController: UINavigationController, modelController: ModelController) {
        self.navigationController = navigationController
        self.modelController = modelController
    }
    
    /// Take control!
    func start() {
        // post details VC
        guard let postDetailsViewController = PostDetailsViewController.instantiate() else { return }
        self.postDetailsViewController = postDetailsViewController
        postDetailsViewController.coordinator = self
        postDetailsViewController.title = "Challenge Accepted!" // Requirement #1: ✅
        
        // no-post details VC
        guard let noPostDetailsViewController = NoPostDetailsViewController.instantiate() else { return }
        self.noPostDetailsViewController = noPostDetailsViewController
        noPostDetailsViewController.title = "Challenge Accepted!" // Requirement #1: ✅
        
        // table view data source (post details)
        let dataSource = PostDetailsDataSource()
        self.dataSource = dataSource
        postDetailsViewController.tableView.dataSource = dataSource
        
        // present it
        navigationController.pushViewController(noPostDetailsViewController, animated: false)
    }
    
}


// MARK: - Post selection delegate

extension PostDetailsCoordinator: PostSelectedDelegate {
    
    // Requirement #9: ✅
    func postSelected(postId: Int64?) {
        // no post selected?
        guard let postId = postId else {
            state = .noSelection
            return
        }

        // get post from Core Data
        modelController.post(with: postId) { [weak self] post in
            guard let post = post else {
                self?.state = .noSelection
                return
            }
            self?.state = .selected(post)
        }
    }
    
}
