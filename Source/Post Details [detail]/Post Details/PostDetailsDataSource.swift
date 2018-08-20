//
//  PostDetailsDataSource.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 16/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostDetailsDataSource: NSObject {
    
    /// Weak reference to parent coordinator.
    weak var coordinator: PostDetailsCoordinator?
    
    /// Model (lightweight, immutable, thread-safe model based of managed objects).
    var post: Post? {
        didSet {
            // attempt to restore previous expanded state
            let isSamePost = oldValue?.id == post?.id
            var previouslyCollapsed: [Int64: Bool]?
            if isSamePost {
                previouslyCollapsed = (albumSections ?? []).reduce([:]) { dictionary, albumSection in
                    var mapping = dictionary
                    mapping?[albumSection.id] = albumSection.isCollapsed
                    return mapping
                }
            }
            
            // compute sections (album titles)
            var sections: [AlbumSection] = []
            for album in post?.user?.albums ?? [] {
                let collapsed = previouslyCollapsed?[album.id] ?? true
                sections.append(AlbumSection(id: album.id, title: album.title, isCollapsed: collapsed))
            }
            self.albumSections = sections
        }
    }
    
    /// Table view sections.
    var albumSections: [AlbumSection]?
    
    /// Struct describing an album title (table section header).
    struct AlbumSection {
        let id: Int64
        let title: String?
        var isCollapsed: Bool
    }
    
    /// Album title header view identifier.
    private let albumTitleHeaderViewIdentifier = "AlbumTitleHeaderViewId"
    
    /// Post details cell identifier.
    private let postDetailsCellIdentifier = "PostDetailsCellId"
    
    /// Post details cell identifier.
    private let postAlbumsCellIdentifier = "PostAlbumsCellId"
    
}

// MARK: - Table data source
extension PostDetailsDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 /* title & body */
            + (albumSections?.count ?? 0) /* user albums */
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // title & body -> 1
        guard section > 0 else { return 1 }
        let albumSectionIndex = section - 1
        
        // album -> depend on collapsed state
        guard let sections = self.albumSections, albumSectionIndex >= 0 && albumSectionIndex < sections.count else { return 0 }
        return sections[albumSectionIndex].isCollapsed ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create cell
        let cellIdentifier = indexPath.section == 0 ? postDetailsCellIdentifier : postAlbumsCellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // non-nil post!
        guard let post = self.post else { return cell }
        
        // set model
        if let postCell = cell as? PostDetailsTableViewCell {
            //  -> post details (title & body)
            postCell.model = PostDetailsTableViewCell.Model(post: post)
        }
        else if let albumsCell = cell as? PostAlbumTableViewCell {
            //  -> albums
            // let coordinator handle the album setup
            coordinator?.setupAlbumCell(albumsCell)
            // set cell's model
            guard let albums = post.user?.albums else {
                albumsCell.model = nil
                return cell
            }
            let albumSectionIndex = indexPath.section - 1
            if albumSectionIndex >= 0 && albumSectionIndex < albums.count {
                albumsCell.model = PostAlbumTableViewCell.Model(photos: albums[albumSectionIndex].photos)
            }
        }
        
        return cell
    }
    
}

// MARK: - Table data delegate
extension PostDetailsDataSource: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // title & body -> (none)
        guard section > 0 else { return nil }
        
        // albums
        guard let sections = self.albumSections else { return nil }
        let albumSectionIndex = section - 1
        guard albumSectionIndex >= 0 && albumSectionIndex < sections.count else { return nil }
        
        // album title (header view) // Requirement #10: ✅ (album title)
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: albumTitleHeaderViewIdentifier) as? PostAlbumTableViewHeaderView ?? PostAlbumTableViewHeaderView(reuseIdentifier: albumTitleHeaderViewIdentifier)
        headerView.configure(with: sections[albumSectionIndex].title,
                             isCollapsed: sections[albumSectionIndex].isCollapsed,
                             section: section,
                             tableView: tableView,
                             delegate: self)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // title & body -> (none)
        guard section > 0 else { return 0 }

        // album titles
        return PostAlbumTableViewHeaderView.headerHeight
    }
}

// MARK: - PostAlbumTableViewHeaderView delegate
extension PostDetailsDataSource: PostAlbumTableViewHeaderViewDelegate {
    
    func tableView(tableView: UITableView?, headerTapped: PostAlbumTableViewHeaderView, section: Int?) {
        guard let section = section else { return }
        let albumSectionIndex = section - 1
        
        // toggle collapsed state
        let currentIsCollapsed = albumSections?[albumSectionIndex].isCollapsed ?? true
        albumSections?[albumSectionIndex].isCollapsed = !currentIsCollapsed
        headerTapped.isCollapsed = !currentIsCollapsed
        
        // update table view header
        tableView?.reloadSections(IndexSet.init(integer: section), with: .automatic)
    }
    
}
