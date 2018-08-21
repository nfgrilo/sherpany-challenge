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
    var childCoordinators: [UITableViewCell: PostAlbumCoordinator] = [:]
    
    /// The navigation view controller currently being used to present view controllers.
    var navigationController: UINavigationController
    
    /// Post details view controller (strong ref: will be in and out of view hierarchy).
    private var postDetailsViewController: PostDetailsViewController?
    
    /// Empty view controller (strong ref: will be in and out of view hierarchy).
    private var noPostDetailsViewController: NoPostDetailsViewController?
    
    /// Model controller.
    private let modelController: ModelController
    
    /// Photo controller.
    private let photoController: PhotoController
    
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
                let postChanged = post.id != (dataSource?.post?.id ?? Int64(NSNotFound))
                dataSource?.post = post
                DispatchQueue.main.async { [weak self] in
                    // remember scrolling offset
                    let previousScrollOffset = viewController.tableView.contentOffset
                    // reload post data
                    self?.postDetailsViewController?.tableView.reloadData()
                    self?.postDetailsViewController?.tableView.layoutIfNeeded()
                    // handle scroll offset
                    if postChanged {
                        // scroll to top (if post changed)
                        viewController.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    }
                    else {
                        // restore scrolling
                        viewController.tableView.contentOffset = previousScrollOffset
                    }
                    // switch view controllers
                    if self?.navigationController.topViewController != viewController {
                        self?.navigationController.viewControllers = [viewController]
                    }
                }
            }
            
        }
    }
    
    
    /// Creates a coordinator.
    ///
    /// - Parameter navigationController: The root view controller "BOSSed" by this coordinator.
    init(navigationController: UINavigationController, modelController: ModelController, photoController: PhotoController) {
        self.navigationController = navigationController
        self.modelController = modelController
        self.photoController = photoController
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
        
        // table view data source & delegate (post details)
        let dataSource = PostDetailsDataSource()
        self.dataSource = dataSource
        dataSource.coordinator = self
        postDetailsViewController.tableView.dataSource = dataSource
        postDetailsViewController.tableView.delegate = dataSource
        
        // present it
        navigationController.pushViewController(noPostDetailsViewController, animated: false)
    }
    
    /// Setup a new/existing cell to show the photos collection.
    ///
    /// - Parameters:
    ///   - cell: The cell that will show the photos collection.
    ///   - album: The `Album` model to setup the cell.
    func setupAlbumCell(_ cell: PostAlbumTableViewCell) {
        // create or reuse coordinator
        let albumCoordinator: PostAlbumCoordinator!
        if let coordinator = childCoordinators[cell] {
            albumCoordinator = coordinator
        }
        else {
            albumCoordinator = PostAlbumCoordinator(cell: cell, modelController: modelController, photoController: photoController)
            albumCoordinator.start()
            childCoordinators[cell] = albumCoordinator
        }
        
        // setup cell delegate
        cell.delegate = albumCoordinator
    }
    
}


// MARK: - Post selection delegate

extension PostDetailsCoordinator: PostSelectedDelegate {
    
    // Requirement #9: ✅ (display the post details)
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
