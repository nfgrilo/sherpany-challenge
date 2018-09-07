//
//  PostDetailsCoordinator.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostDetailsCoordinator: Coordinator {
    
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
    
    /// Map of child view controllers to coordinators.
    ///
    /// This is needed when poping (returning from) child view controllers, so
    /// that the coordinator can be deallocated (by removing it from `childCoordinators`).
    private var viewControllersToChildCoordinators: [UIViewController: Coordinator] = [:]
    
    
    // MARK: - Coordinator setup
    
    /// Creates a coordinator.
    ///
    /// - Parameter navigationController: The root view controller "BOSSed" by this coordinator.
    init(navigationController: UINavigationController, modelController: ModelController, photoController: PhotoController) {
        self.navigationController = navigationController
        self.modelController = modelController
        self.photoController = photoController
    }
    
    /// Take control!
    override func start() {
        // no-post details VC
        guard let noPostDetailsViewController = NoPostDetailsViewController.instantiate() else { return }
        self.noPostDetailsViewController = noPostDetailsViewController
        noPostDetailsViewController.title = "Challenge Accepted!" // Requirement #1: ✅
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.tintColor = .white
        
        // post details VC
        guard let postDetailsViewController = PostDetailsViewController.instantiate() else { return }
        self.postDetailsViewController = postDetailsViewController
        postDetailsViewController.title = "Challenge Accepted!" // Requirement #1: ✅
        navigationController.navigationBar.barTintColor = UIColor(named: "Navigation Bar") ?? .clear
        navigationController.navigationBar.barStyle = .black
        
        // post details vc: collection view data source & delegate
        //  -> layout
        let flowLayout = PostAlbumCollectionViewFlowLayout()
        //      > Using `flowLayout.estimatedItemSize` instead of `itemSize`
        //      > would enable dynamic cell sizing. However, this causes lagging
        //      > animations when refreshing the collection view item.
        //      > Using static size instead.
        //flowLayout.estimatedItemSize = CGSize(width: 190, height: 228)
        flowLayout.itemSize = CGSize(width: 190, height: 228)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionHeadersPinToVisibleBounds = true // Bonus #2: ✅ (stick headers to the top)
        postDetailsViewController.collectionView?.collectionViewLayout = flowLayout
        //  -> data source
        let dataSource = PostDetailsDataSource(photoController: photoController)
        self.dataSource = dataSource
        dataSource.delegate = self
        dataSource.collectionView = postDetailsViewController.collectionView
        postDetailsViewController.collectionView?.dataSource = dataSource
        postDetailsViewController.collectionView?.delegate = dataSource
        postDetailsViewController.collectionView?.prefetchDataSource = dataSource
        //  -> post details supplementary view
        postDetailsViewController.collectionView?.register(PostDetailsHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: PostDetailsHeaderView.viewIdentifier)
        
        // present it
        navigationController.delegate = self
        navigationController.pushViewController(noPostDetailsViewController, animated: false)
    }
    
    
    // MARK: - State (post selection)
    
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
                    // cancel current photo network requests
                    photoController.cancelAllPhotoFetchs()
                }
                // -> present post details VC
                dataSource?.post = post
                DispatchQueue.main.async { [weak self] in
                    // reload data
                    viewController.reloadData(restoreScrolling: !postChanged)
                    
                    // switch view controllers
                    guard let topViewController = self?.navigationController.topViewController else { return }
                    let isShowingFullscreenPhoto = topViewController is FullscreenPhotoViewController
                    let isShowingPostDetails = topViewController == viewController
                    
                    if postChanged && isShowingFullscreenPhoto {
                        // post changed & a full screen photo was being viewed -> manually pop it
                        self?.navigationController.popViewController(animated: false)
                    }
                    if postChanged && !isShowingPostDetails {
                        self?.navigationController.viewControllers = [viewController]
                    }
                }
            }
            
        }
    }
    
    /// Show full screen photo by loading a new coordinator.
    ///
    /// - Parameter photo: The photo to be shown.
    func showFullscreenPhoto(with photo: Photo) {
        // setup coordinator
        let coordinator = FullscreenPhotoCoordinator(navigationController: navigationController, photoController: photoController, photo: photo)
        
        // keep child coordinator reference
        addChild(coordinator)
        
        // let coordinator take control
        coordinator.start()
        
        // map this VC to this coordinator
        if let vc = coordinator.viewController {
            viewControllersToChildCoordinators[vc] = coordinator
        }
    }
    
}


// MARK: - Post selection delegate
extension PostDetailsCoordinator: PostDetailsDataSourceDelegate {
    
    func photoWasTapped(_ photo: Photo) {
        // show full-sized photo
        showFullscreenPhoto(with: photo)
    }
    
}


// MARK: - Post selection delegate
extension PostDetailsCoordinator: PostsCoordinatorDelegate {
    
    // Requirement #9: ✅ (display the post details)
    func postWasSelected(postId: Int64?) {
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


// MARK: Navigation controller delegate
extension PostDetailsCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // ensure the view controller is popping
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
            !navigationController.viewControllers.contains(fromViewController) else {
            return
        }
        
        // remove child coordinator
        if let coordinator = viewControllersToChildCoordinators[fromViewController] {
            viewControllersToChildCoordinators.removeValue(forKey: fromViewController)
            removeChild(coordinator)
        }
    }
    
}
