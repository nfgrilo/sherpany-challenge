//
//  PostDetailsViewController.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 13/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostDetailsViewController: UITableViewController, Storyboarded {
    
    /// Weak reference to parent coordinator.
    weak var coordinator: PostDetailsCoordinator?
    
    
    // MARK: - Table view setup
    
    override func viewDidLoad() {
        // dynamic row heights based on auto layout
        tableView.rowHeight = UITableViewAutomaticDimension
    }

}

