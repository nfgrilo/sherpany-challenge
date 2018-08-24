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
    
    /// Model controller.
    private let modelController: ModelController
    
    /// Model (lightweight, immutable, thread-safe model based of managed objects).
    private var model: [Post] = []
    
    /// Cell identifier.
    private let cellIdentifier = "PostCellId"
    
    /// Initialize data source.
    ///
    /// - Parameter modelController: The shared model controller.
    init(modelController: ModelController) {
        self.modelController = modelController
    }
    
}


// MARK: Table view data source
extension PostsDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create cell
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // set model
        if let postCell = cell as? PostTableViewCell, let post = self.post(at: indexPath) {
            postCell.model = PostTableViewCell.Model(post: post)
        }
        
        return cell
    }
    
}


// MARK: Table view delegate
extension PostsDataSource: UITableViewDelegate {
    
    // MARK: Post selection
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // inform post selection delegate that selected post has been changed
        coordinator?.postSelected(in: tableView, at: indexPath)
    }
    
    
    // MARK: Swipe to delete
    // Requirement #8: ✅
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // delete action
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            // inform coordinator that selected post has been deleted from table view
            self?.coordinator?.postDeleted(in: tableView, at: indexPath)
        }
        
        return [delete]
    }
}


// MARK: Model related
extension PostsDataSource {
    
    /// Get a post by index path.
    ///
    /// - Parameter indexPath: Table's index path
    /// - Returns: The corresponding `Post` object, if any.
    func post(at indexPath: IndexPath) -> Post? {
        guard indexPath.row < model.count else {
            return nil
        }
        return model[indexPath.row]
    }
    
    /// Get the table view index path for a given Post id.
    ///
    /// - Parameter postId: The post id to be looked up.
    /// - Returns: The corresponding index path.
    func indexPath(for postId: Int64) -> IndexPath? {
        for row in 0..<model.count {
            if model[row].id == postId {
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
