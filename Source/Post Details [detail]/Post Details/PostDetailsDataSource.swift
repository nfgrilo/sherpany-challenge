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
    
    /// Photo controller.
    private let photoController: PhotoController
    
    /// Initializes the data source.
    ///
    /// - Parameter photoController: The shared photo controller.
    init(photoController: PhotoController) {
        // photo controller
        self.photoController = photoController
        
        super.init()
        
        // setup dispatch source
        let source = DispatchSource.makeUserDataAddSource(queue: DispatchQueue.main)
        source.setEventHandler { [weak self] in
            self?.refreshPendingCollectionViewItems()
        }
        source.activate()
        collectionViewUpdateSource = source
    }
    
    deinit {
        collectionViewUpdateSource?.cancel()
    }
    
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
    
    /// Post details cell identifier.
    private let postDetailsCellIdentifier = "PostDetailsCellId" // unused?
    
    /// Post details cell identifier.
    private let postAlbumsCellIdentifier = "PostAlbumsCellId" // unused?
    
    /// Photo cell identifier.
    private let photoCellIdentifier = "PhotoCellId"
    
    /// Weak reference to collection view.
    private weak var collectionView: UICollectionView?
    
    /// Dispatch source for updating collection view.
    private var collectionViewUpdateSource: DispatchSourceUserDataAdd?
    
    /// Items in queue to be reloaded.
    private var collectionViewItemsToUpdate: [IndexPath] = []
    
    /// Refresh collection view items needing refresh.
    private func refreshPendingCollectionViewItems() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        collectionView?.reloadItems(at: collectionViewItemsToUpdate)
        collectionView?.setNeedsLayout()
        collectionView?.layoutIfNeeded()
        CATransaction.commit()
        collectionViewItemsToUpdate.removeAll()
    }
    
    /// Coalesce collection view item updates.
    ///
    /// - Parameter indexPaths: Index paths of items needing refresh.
    public func appendPendingCollectionViewItems(_ indexPaths: [IndexPath]) {
        collectionViewItemsToUpdate.append(contentsOf: indexPaths)
        collectionViewUpdateSource?.add(data: 1)
    }
    
}

// MARK: - Collection view data source
extension PostDetailsDataSource: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return albumSections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let albums = post?.user?.albums, section < albums.count,
            let sections = self.albumSections, section < sections.count else {
            return 0
        }
        
        // section is collpased?
        return sections[section].isCollapsed ? 0 : albums[section].photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // create cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath)
        
        // set model
        guard let photoCell = cell as? PostAlbumCollectionViewCell,
            let photo = photo(for: indexPath) else {
            return cell
        }
        let title = photo.title
        let imageUrl = photo.thumbnailUrl
        let image = photoController.photo(for: imageUrl)
        photoCell.model = PostAlbumCollectionViewCell.Model(title: title, photo: image)
        
        // no photo yet? -> fetch
        if image == nil, let imageUrl = imageUrl {
            photoController.fetchPhotos(from: [imageUrl]) { [weak self] _, image in
                // update cell's model (without animation)
                photoCell.model = PostAlbumCollectionViewCell.Model(title: title, photo: image)
                self?.appendPendingCollectionViewItems([indexPath])
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        // create header
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PostAlbumHeaderView.viewIdentifier, for: indexPath)
        if let view = headerView as? PostAlbumHeaderView, let sections = self.albumSections {
            view.configure(with: sections[indexPath.section].title,
                           isCollapsed: sections[indexPath.section].isCollapsed,
                           section: indexPath.section,
                           collectionView: collectionView,
                           delegate: self)
        }
        
        return headerView
    }
    
    /// Get the photo associated with the given index path.
    ///
    /// - Parameter indexPath: The post index path.
    /// - Returns: A photo.
    func photo(for indexPath: IndexPath) -> Photo? {
        guard let albums = post?.user?.albums,
            indexPath.section < albums.count,
            indexPath.row < albums[indexPath.section].photos.count else {
                return nil
        }
        return albums[indexPath.section].photos[indexPath.row]
    }
    
}


// MARK: - Prefetching data source
extension PostDetailsDataSource: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // asynchronously fetch photos
        let urls = indexPaths.compactMap { photo(for: $0)?.thumbnailUrl }
        photoController.fetchPhotos(from: urls)
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        // slow down any current photo requests
        let urls = indexPaths.compactMap { photo(for: $0)?.thumbnailUrl }
        photoController.slowdownPhotoFetches(urls: urls)
    }
    
}


// MARK: - Collection view flow layout delegate
extension PostDetailsDataSource: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 100, height: PostAlbumHeaderView.headerHeight)
    }
    
}


// MARK: - Collection view delegate
extension PostDetailsDataSource: UICollectionViewDelegate {
    
}


// MARK: - PostAlbumHeaderViewDelegate delegate
extension PostDetailsDataSource: PostAlbumHeaderViewDelegate {
    
    func tableView(collectionView: UICollectionView?, headerTapped: PostAlbumHeaderView, section: Int?) {
        guard let section = section else { return }
        
        // toggle collapsed state
        let currentIsCollapsed = albumSections?[section].isCollapsed ?? true
        albumSections?[section].isCollapsed = !currentIsCollapsed
        headerTapped.isCollapsed = !currentIsCollapsed
        
        // reload section
        collectionView?.reloadSections(IndexSet.init(integer: section))
    }
    
}
