//
//  PostsViewController.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostsViewController: UITableViewController, Storyboarded {
    
    /// Weak reference to parent coordinator.
    weak var coordinator: PostsCoordinator?
    
    
    // MARK: - Table view setup
    
    override func viewDidLoad() {
        // dynamic row heights based on auto layout
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // height estimate helps improving performance on row height calculation
        tableView.estimatedRowHeight = 84
    }
    
    
    // MARK: - Post selection
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // inform post selection delegate that selected post has been changed
        coordinator?.postSelected(in: tableView, at: indexPath)
    }
    
    
    // MARK: - Swipe to delete
    // Requirement #8: ✅
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // delete action
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            // inform coordinator that selected post has been deleted from table view
            self?.coordinator?.postDeleted(in: tableView, at: indexPath)
        }
        
        return [delete]
    }
    
}
