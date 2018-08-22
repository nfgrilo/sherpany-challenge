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
                // post changed?
                let postChanged = post.id != (dataSource?.post?.id ?? Int64(NSNotFound))
                if postChanged {
                    // cancel current photo network request
                    photoController.cancelAllPhotoFetchs()
                }
                // -> present post details VC
                dataSource?.post = post
                DispatchQueue.main.async { [weak self] in
                    guard let collectionView = viewController.collectionView else { return }
                    // remember scrolling offset
                    let previousScrollOffset = collectionView.contentOffset
                    // reload post data & layout
                    collectionView.reloadData()
                    collectionView.setNeedsLayout()
                    collectionView.layoutIfNeeded()
                    // handle scroll offset
                    if postChanged {
                        // scroll to top if post changed
                        var offset = CGPoint(x: -collectionView.contentInset.left, y: -collectionView.contentInset.top)
                        if #available(iOS 11.0, *) {
                            offset = CGPoint(x: -collectionView.adjustedContentInset.left, y: -collectionView.adjustedContentInset.top)
                        }
                        collectionView.setContentOffset(offset, animated: false)
                    }
                    else {
                        // restore previous scrolling offset
                        collectionView.contentOffset = previousScrollOffset
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
        // no-post details VC
        guard let noPostDetailsViewController = NoPostDetailsViewController.instantiate() else { return }
        self.noPostDetailsViewController = noPostDetailsViewController
        noPostDetailsViewController.title = "Challenge Accepted!" // Requirement #1: ✅
        
        // post details VC
        guard let postDetailsViewController = PostDetailsViewController.instantiate() else { return }
        self.postDetailsViewController = postDetailsViewController
        postDetailsViewController.coordinator = self
        postDetailsViewController.title = "Challenge Accepted!" // Requirement #1: ✅
        
        // post details vc: collection view data source & delegate
        //  -> layout
        let flowLayout = PostAlbumCollectionViewFlowLayout()
        //      > Using `flowLayout.estimatedItemSize` instead of `itemSize`
        //      > would enable dynamic cell sizing. However, this causes lagging
        //      > animations when refreshing the cell photo. Using static size
        //      > instead.
//        flowLayout.estimatedItemSize = CGSize(width: 190, height: 228)
        flowLayout.itemSize = CGSize(width: 190, height: 228)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionHeadersPinToVisibleBounds = true // Bonus Point #2: ✅
        postDetailsViewController.collectionView?.collectionViewLayout = flowLayout
        //  -> data source
        let dataSource = PostDetailsDataSource(photoController: photoController)
        self.dataSource = dataSource
        dataSource.coordinator = self
        postDetailsViewController.collectionView?.dataSource = dataSource
        postDetailsViewController.collectionView?.delegate = dataSource
        postDetailsViewController.collectionView?.prefetchDataSource = dataSource
        
        // present it
        navigationController.pushViewController(noPostDetailsViewController, animated: false)
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
