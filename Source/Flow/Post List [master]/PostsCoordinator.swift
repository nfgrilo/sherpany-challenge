//
//  PostsCoordinator.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

// Requirement #7: ✅ (display table with all posts...)

class PostsCoordinator: Coordinator {
    
    /// The navigation view controller currently being used to present view controllers.
    var navigationController: UINavigationController
    
    /// Posts coordinator delegate (post selection).
    weak var delegate: PostsCoordinatorDelegate?
    
    /// Weak reference to presented view controller.
    ///
    /// A strong reference is already made when vc is presented (added to vc hierarchy).
    weak var viewController: PostsViewControllerProtocol?
    
    /// The posts search controller.
    var searchController: UISearchController?
    
    /// Model controller.
    private let modelController: ModelController
    
    /// Posts data source.
    var dataSource: PostsDataSource?
    
    /// Currently selected post
    var selectedPost: Post?
    
    
    /// Creates a new coordinator.
    ///
    /// - Parameter navigationController: The root view controller "BOSSed" by this coordinator.
    init(navigationController: UINavigationController, modelController: ModelController) {
        self.navigationController = navigationController
        self.modelController = modelController
    }
    
    
    /// Take control!
    override func start() {
        // model controller delegate
        modelController.addDelegate(self)
        
        // view controller
        guard let viewController = createViewController() else { return }
        self.viewController = viewController
        
        // data source
        let dataSource = createDataSource(for: viewController.tableView)
        self.dataSource = dataSource
        loadInitialData(in: viewController.tableView)
        
        // search
        let searchController = createSearchController(on: viewController, resultsUpdater: dataSource)
        self.searchController = searchController
        dataSource.searchController = searchController
        
        // navigation bar
        setupNavigationBar()
        
        // present it
        navigationController.pushViewController(viewController, animated: false)
    }
    
    /// Create and configure the managed view controller.
    func createViewController() -> PostsViewController? {
        guard let viewController = PostsViewController.instantiate() else { return nil }
        viewController.loadViewIfNeeded()
        viewController.title = "Posts"
        return viewController
    }
    
    /// Create and configure the (table view) data source.
    func createDataSource(for tableView: UITableView) -> PostsDataSource {
        let dataSource = PostsDataSource(modelController: modelController)
        dataSource.delegate = self
        dataSource.tableView = tableView
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        return dataSource
    }
    
    /// Load initial data.
    ///
    /// Must be called after data source has been setup.
    func loadInitialData(in tableView: UITableView, completion: (() -> Void)? = nil) {
        guard let dataSource = self.dataSource else { completion?(); return }
        dataSource.refreshPostList(in: tableView, completion: completion)
    }
    
    /// Create and configure the search view controller.
    func createSearchController(on viewController: UIViewController, resultsUpdater: UISearchResultsUpdating) -> UISearchController {
        // Bonus #3: ✅ (include search bar)
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = resultsUpdater
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Posts"
        viewController.navigationItem.searchController = searchController
        viewController.definesPresentationContext = true
        return searchController
    }
    
    /// Configures the navigation bar.
    func setupNavigationBar() {
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.barTintColor = UIColor(named: "Navigation Bar") ?? .clear
        navigationController.navigationBar.barStyle = .black
    }
    
}


// MARK: - PostsDataSourceDelegate delegate
extension PostsCoordinator: PostsDataSourceDelegate {
    func postWasSelected(_ post: Post?) {
        // remember selection
        selectedPost = post
        
        // inform post selection delegate that selected post has been changed
        delegate?.postWasSelected(postId: post?.id)
    }
    
    func postWasDeleted(_ post: Post) {
        // nothing to do
    }
    
    func searchFeedbackDidChange(_ searchFeedback: String?) {
        viewController?.setSearchFeedbackView(with: searchFeedback)
    }
}


// MARK: - ModelController delegate
extension PostsCoordinator: ModelControllerDelegate {
    func postWasRemoved(postId: Int64) {
        // nothing to do
    }
    
    func dataWillRefresh() {
        // show loading indicator
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showProgressView(true)
        }
    }
    
    func dataDidRefresh(success: Bool) {
        // hide loading indicator
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showProgressView(false)
        }
        
        guard let tableView = viewController?.tableView else { return  }
        
        // refresh data source
        dataSource?.refreshPostList(in: tableView) { [weak self] in
            // 1. if the user was searching, update and restore search results
            if self?.dataSource?.isSearching() ?? false, let searchController = self?.searchController {
                self?.dataSource?.updateSearchResults(for: searchController)
            }
            
            // 2. select previous post
            //    The call to `updateSearchResults(for:)` will invoke `reloadData()`
            //    so selection can only be restored on the next runloop (after data reload).
            DispatchQueue.main.async {
                // re-select post (if any was previously selected)
                // ps: this closure runs on main thread
                if let previousSelectedPostId = self?.selectedPost?.id,
                    let newSelection = self?.dataSource?.indexPath(for: previousSelectedPostId) {
                    // select and call appropriate table view controller delegate methods
                    // so notifications are sent to observers
                    let _ = tableView.delegate?.tableView?(tableView, willSelectRowAt: newSelection)
                    tableView.selectRow(at: newSelection, animated: false, scrollPosition: .none)
                    tableView.delegate?.tableView?(tableView, didSelectRowAt: newSelection)
                }
            }
        }
    }
}
