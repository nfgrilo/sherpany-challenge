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
    
    /// Post selection delegate.
    weak var postSelectedDelegate: PostSelectedDelegate?
    
    /// Weak reference to presented view controller.
    ///
    /// A strong reference is already made when vc is presented (added to vc hierarchy).
    private weak var viewController: PostsViewController?
    
    /// The posts search controller.
    private var searchController: UISearchController?
    
    /// Model controller.
    private let modelController: ModelController
    
    /// Posts data source.
    private var dataSource: PostsDataSource?
    
    /// Currently selected post
    private var selectedPost: Post?
    
    
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
        
        // create & setup vc
        guard let viewController = PostsViewController.instantiate() else { return }
        self.viewController = viewController
        viewController.coordinator = self
        viewController.loadViewIfNeeded()
        viewController.title = "Posts"
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.barTintColor = UIColor(named: "Navigation Bar") ?? .clear
        navigationController.navigationBar.barStyle = .black
        
        // table view data source
        let dataSource = PostsDataSource(modelController: modelController)
        self.dataSource = dataSource
        dataSource.coordinator = self
        dataSource.tableView = viewController.tableView
        viewController.tableView.dataSource = dataSource
        viewController.tableView.delegate = dataSource
        dataSource.refreshPostList(in: viewController.tableView)
        
        // setup search
        // Bonus #3: ✅ (include search bar)
        let searchController = UISearchController(searchResultsController: nil)
        self.searchController = searchController
        dataSource.searchController = searchController
        searchController.searchResultsUpdater = dataSource
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Posts"
        viewController.navigationItem.searchController = searchController
        viewController.definesPresentationContext = true
        
        // present it
        navigationController.pushViewController(viewController, animated: false)
    }
    
    /// Called from table view controller when a post has been selected.
    ///
    /// - Parameter id: The index path of selected post.
    func postSelected(in tableView: UITableView, at indexPath: IndexPath) {
        // remember selection
        selectedPost = dataSource?.post(at: indexPath)
        
        // inform post selection delegate that selected post has been changed
        if let postId = selectedPost?.id {
            postSelectedDelegate?.postSelected(postId: postId)
        }
    }
    
    /// Called from table view controller when a post has been deleted.
    ///
    /// - Parameter id: The index path of selected post.
    func postDeleted(in tableView: UITableView, at indexPath: IndexPath) {
        // remove from Core Data
        dataSource?.removePost(in: tableView, at: indexPath)
        
        // inform post selection delegate that selected post has been changed
        postSelectedDelegate?.postSelected(postId: nil)
    }
    
    /// Show search feedback to the user.
    ///
    /// - Parameter text: Text to display.
    func setSearchFeedback(_ text: String?) {
        viewController?.setSearchFeedbackView(with: text)
    }
}


// MARK: - ModelController delegate
extension PostsCoordinator: ModelControllerDelegate {
    func postWasRemoved(postId: Int64) {
        // do nothing - already handled
    }
    
    func dataWillRefresh() {
        // show loading indicator
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showProgressView(true)
        }
    }
    
    func dataDidRefresh() {
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
