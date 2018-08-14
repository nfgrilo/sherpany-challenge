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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // inform post selection delegate that selected post has been changed
        coordinator?.postSelectedDelegate?.postSelected(id: indexPath.row)
    }
    
}
