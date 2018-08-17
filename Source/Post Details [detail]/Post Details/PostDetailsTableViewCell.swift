//
//  PostDetailsTableViewCell.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 16/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostDetailsTableViewCell: UITableViewCell {
    
    /// Post title label.
    @IBOutlet weak var postTitle: UILabel!
    
    /// Post body label.
    @IBOutlet weak var postBody: UILabel!
    
    /// View-model.
    var model: Model? {
        didSet {
            guard let model = model else {
                return
            }
            
            // update UI
            postTitle.text = model.title
            postBody.text = model.body
        }
    }
}


/// Posts Details table view cell view-model.
extension PostDetailsTableViewCell {
    struct Model {
        let title: String
        let body: String
        
        init(post: Post) {
            title = post.title ?? "(untitled post)"
            body = post.body ?? ""
        }
    }
}
