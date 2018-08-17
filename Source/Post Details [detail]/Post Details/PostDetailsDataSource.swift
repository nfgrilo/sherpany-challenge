//
//  PostDetailsDataSource.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 16/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostDetailsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
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
            guard let albums = post.user?.albums else {
                albumsCell.model = nil
                return cell
            }
            let index = indexPath.section - 1
            if index >= 0 && index < albums.count {
                albumsCell.model = PostAlbumTableViewCell.Model(photos: albums[index].photos)
            }
        }
        
        return cell
    }
    
    
    // MARK: - Table data delegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // title & body -> (none)
        guard section > 0 else { return nil }
        
        // albums
        guard let albums = post?.user?.albums else { return nil }
        let index = section - 1
        guard index >= 0 && index < albums.count else { return nil }
        
        // album title (header view) // Requirement #10: ✅ (album title)
        let albumTitle =  albums[index].title
        let headerView = createAlbumTitleView(title: albumTitle)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // title & body -> (none)
        guard section > 0 else { return 0 }
        
        // album titles
        return 40
    }
    
    private func createAlbumTitleView(title: String?) -> UIView {
        // header view
        let blurEffect = UIBlurEffect(style: .extraLight)
        let headerView = UIVisualEffectView(effect: blurEffect)
        
        // album title
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        if let albumTitleColor = UIColor(named: "Album Title") {
            label.textColor = albumTitleColor
        }
        label.text = title ?? "(untitled album)"
        label.numberOfLines = 0
        
        // layout
        headerView.contentView.addSubview(label)
        let views: [String: Any] = ["title": label]
        let options: NSLayoutFormatOptions = .init(rawValue: 0)
        headerView.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[title]-20-|", options: options, metrics: nil, views: views))
        headerView.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[title]-8-|", options: options, metrics: nil, views: views))
        
        return headerView
    }
    
}
