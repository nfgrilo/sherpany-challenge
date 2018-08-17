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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 /* title & body */
            + (post?.user?.albums.count ?? 0) /* user albums */
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create cell
        let cellIdentifier = indexPath.section == 0 ? postDetailsCellIdentifier : postAlbumsCellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // non-nil post!
        guard let post = self.post else { return cell }
        
        // set model
        if let postCell = cell as? PostDetailsTableViewCell {
            postCell.model = PostDetailsTableViewCell.Model(post: post)
        }
        else if let albumsCell = cell as? PostAlbumTableViewCell {
            guard let albums = post.user?.albums else { return cell }
            let index = indexPath.section - 1
            if index >= 0 && index < albums.count {
                albumsCell.model = PostAlbumTableViewCell.Model(photos: albums[index].photos)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // title & body -> (none)
        guard section > 0 else { return nil }
        
        // albums
        guard let albums = post?.user?.albums else { return nil }
        let index = section - 1
        guard index >= 0 && index < albums.count else { return nil }
        
        // Requirement #10: ✅ (album title)
        return albums[index].title
    }
}
