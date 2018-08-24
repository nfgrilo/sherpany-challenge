//
//  PostTableViewCell.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 16/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

/// Posts table view cell.
class PostTableViewCell: UITableViewCell {
    
    /// Reusable view identifier.
    static let viewIdentifier = "PostTableViewCell"
    
    /// Post title label.
    @IBOutlet weak var postTitle: UILabel!
    
    /// Post author label.
    @IBOutlet weak var postAuthor: UILabel!
    
    /// View-model.
    var model: Model? {
        didSet {
            guard let model = model else {
                return
            }
            
            // update UI
            postTitle.text = model.title
            postAuthor.text = model.author
        }
    }
}


/// Posts table view cell view-model.
extension PostTableViewCell {
    struct Model {
        let title: String
        let author: String
        
        init(post: Post) {
            title = post.title ?? "(untitled post)"
            author = post.user?.email ?? "(unknown author)"
        }
    }
}
