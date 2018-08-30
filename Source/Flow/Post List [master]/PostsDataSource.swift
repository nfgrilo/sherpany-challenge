//
//  PostsDataSource.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostsDataSource: NSObject {
    
    /// Weak reference to parent coordinator.
    weak var coordinator: PostsCoordinator?
    
    /// Search controller.
    var searchController: UISearchController?
    
    /// Weak reference to table view.
    weak var tableView: UITableView?
    
    /// Currently selected index path.
    ///
    /// Need to keep track of this, so that selection & highlighting doesn't
    /// flickr or get lost when scrolling (specially, for the first time).
    var selectedIndexPath: IndexPath?
    
    /// Model controller.
    private let modelController: ModelController
    
    /// Model (lightweight, immutable, thread-safe model based of managed objects).
    private var model: [Post] = []
    
    /// Filtered model, after filtering model with search results.
    private var filteredModel: [Post] = []
    
    /// Initialize data source.
    ///
    /// - Parameter modelController: The shared model controller.
    init(modelController: ModelController) {
        self.modelController = modelController
    }
    
}


// MARK: - Table view data source
extension PostsDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // search feedback
        updateSearchFeedback()
        
        // total posts (all or filtered)
        return postsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create cell
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.viewIdentifier, for: indexPath)
        
        // setup cell
        guard let postCell = cell as? PostTableViewCell, let post = self.post(at: indexPath) else {
            return cell
        }
        
        // cell model
        postCell.model = PostTableViewCell.Model(post: post)
        
        // cell selection view
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor(named: "Post Selection") ?? .lightGray
        postCell.selectedBackgroundView = selectionView
        
        return postCell
    }
    
}


// MARK: - Table view delegate
extension PostsDataSource: UITableViewDelegate {
    
    // MARK: Post selection
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // keep track of selection
        selectedIndexPath = indexPath
        
        // inform post selection delegate that selected post has been changed
        coordinator?.postSelected(in: tableView, at: indexPath)
    }
    
    
    // MARK: Swipe to delete
    // Requirement #8: ✅
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // delete action
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            // deleted currently selected cell?
            if indexPath == self?.selectedIndexPath {
                // -> clear selection
                self?.selectedIndexPath = nil
                
                // -> inform post selection delegate that selected post has been changed
                self?.coordinator?.postSelected(in: tableView, at: nil)
            }
            
            // inform coordinator that selected post has been deleted from table view
            self?.coordinator?.postDeleted(in: tableView, at: indexPath)
        }
        
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // don't allow deletes while searching or refreshing data!
        return !isSearching() && !isRefreshingData()
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        // restore selection (if it wasn't removed)
        if indexPath != selectedIndexPath, let oldSelection = selectedIndexPath {
            // -> do it on next run loop
            DispatchQueue.main.async {
                tableView.selectRow(at: oldSelection, animated: false, scrollPosition: .none)
            }
        }
    }
    
    /// Check if data is currently being updated.
    ///
    /// - Returns: Whether data is being updated (fetched & merged into Core Data).
    func isRefreshingData() -> Bool {
        return coordinator?.isRefreshingData ?? false
    }
    
}


// MARK: - Searching
extension PostsDataSource: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterModel(with: searchController.searchBar.text)
    }
    
    /// Update the UI search feedback text.
    func updateSearchFeedback() {
        var searchFeedback: String?
        if !isSearchBarEmpty() {
            if filteredModel.count == 0 {
                searchFeedback = "No Search Results"
            }
            else {
                searchFeedback = "Filtering \(filteredModel.count) of \(model.count) Posts"
            }
        }
        else {
            searchFeedback = nil
        }
        coordinator?.setSearchFeedback(searchFeedback)
    }
    
    /// Check if user is currently searching.
    ///
    /// - Returns: Whether a search is being made.
    func isSearching() -> Bool {
        return (searchController?.isActive ?? false) && !isSearchBarEmpty()
    }
    
    /// Check if search bar contains any text.
    ///
    /// - Returns: Whether search bar has text.
    private func isSearchBarEmpty() -> Bool {
        guard let searchController = self.searchController else { return true }
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    /// Filter current model with search text.
    ///
    /// - Parameter searchText: The text to search for.
    private func filterModel(with searchText: String?) {
        // reset filtered results to all results if no search text
        guard let searchText = searchText?.lowercased() else {
            filteredModel = model
            return
        }
        
        // filter post (title & author email) by specified search text
        filteredModel = model.filter {
            guard let postTitle = $0.title?.lowercased(),
                  let postAuthorEmail = $0.user?.email?.lowercased()else {
                    return false
            }
            return postTitle.contains(searchText)
                || postAuthorEmail.contains(searchText)
        }
        
        // reload posts
        DispatchQueue.main.async { [weak self] in
            self?.tableView?.reloadData()
        }
    }
}


// MARK: - Model related
extension PostsDataSource {
    
    /// Gets the active model.
    ///
    /// If searching, the returned model will be filtered.
    ///
    /// - Returns: The active model.
    func activeModel() -> [Post] {
        return isSearching() ? filteredModel : model
    }
    
    /// Get total posts.
    ///
    /// - Returns: The total number of posts.
    func postsCount() -> Int {
        return activeModel().count
    }
    
    /// Get a post by index path.
    ///
    /// - Parameter indexPath: Table's index path
    /// - Returns: The corresponding `Post` object, if any.
    func post(at indexPath: IndexPath) -> Post? {
        // choose model dependeing on whether there is a search going on
        let currentModel = activeModel()
        
        // make sure `indexPath` is within bounds
        guard indexPath.row < currentModel.count else {
            return nil
        }
        
        return currentModel[indexPath.row]
    }
    
    /// Get the table view index path for a given Post id.
    ///
    /// - Parameter postId: The post id to be looked up.
    /// - Returns: The corresponding index path.
    func indexPath(for postId: Int64) -> IndexPath? {
        // choose model dependeing on whether there is a search going on
        let currentModel = activeModel()
        
        // find model item
        for row in 0..<currentModel.count {
            if currentModel[row].id == postId {
                return IndexPath(row: row, section: 0)
            }
        }
        
        return nil
    }
    
    /// Refresh post list.
    func refreshPostList(in tableView: UITableView, completion: (() -> Void)? = nil) {
        // retrieve all posts
        modelController.allPosts { [weak self] posts in
            // update model
            self?.model = posts
            
            DispatchQueue.main.async {
                // refresh table
                tableView.reloadData()
                
                // done
                completion?()
            }
        }
    }
    
    /// Remove a post.
    func removePost(in tableView: UITableView, at indexPath: IndexPath) {
        // get post being removed
        guard let post = self.post(at: indexPath) else {
            return
        }
        
        // remove from Core Data
        modelController.removePost(post.id) { [weak self] in
            // remove from table data source
            if let modelIndex = self?.model.index(of: post) {
                self?.model.remove(at: modelIndex)
            }
            
            // remove row from table view
            DispatchQueue.main.async {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
}
