//
//  PostDetailsDataSource.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 16/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostDetailsDataSource: NSObject, UITableViewDataSource {
    
    /// Model (lightweight, immutable, thread-safe model based of managed objects).
    var post: Post?
    
    /// Post details cell identifier.
    private let postDetailsCellIdentifier = "PostDetailsCellId"
    
    /// Post details cell identifier.
    private let postAlbumsCellIdentifier = "PostAlbumsCellId"
    
    
    // MARK: - Table data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create cell
        let cellIdentifier = indexPath.row == 0 ? postDetailsCellIdentifier : postAlbumsCellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // we should have a non-nil post
        guard let post = self.post else { return cell }
        
        // set model
        if let postCell = cell as? PostDetailsTableViewCell {
            postCell.model = PostDetailsTableViewCell.Model(post: post)
        }
//        else if let albumsCell = cell as? PostAlbumTableViewCell {
//            albumsCell.model = PostAlbumTableViewCell.Model(post: post)
//        }
        
        return cell
    }
}
