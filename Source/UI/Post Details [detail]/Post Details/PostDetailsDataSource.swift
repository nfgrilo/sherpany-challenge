//
//  PostDetailsDataSource.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 16/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

// Requirement #10: ✅ (related albums)

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
        
        // setup dispatch source (to coalesce collection view updates)
        let source = DispatchSource.makeUserDataAddSource(queue: DispatchQueue.main)
        source.setEventHandler { [weak self] in
            self?.refreshCollectionViewItems()
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
    
    /// Weak reference to collection view.
    weak var collectionView: UICollectionView?
    
    
    // MARK: - Coalesced collection view item updates
    
    /// Dispatch source for updating collection view.
    private var collectionViewUpdateSource: DispatchSourceUserDataAdd?
    
    /// Refresh collection view items needing refresh.
    private func refreshCollectionViewItems() {
        // find cells whose model has no photo yet
        var indexPaths: [IndexPath] = []
        if let visibleCells = collectionView?.visibleCells {
            for cell in visibleCells {
                if let cell = cell as? PostAlbumCollectionViewCell,
                    cell.model?.photo == nil,
                    let cellIndexPath = collectionView?.indexPath(for: cell) {
                    indexPaths.append(cellIndexPath)
                }
            }
        }
        
        // reload those items (without animation)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        collectionView?.reloadItems(at: indexPaths)
        CATransaction.commit()
    }
    
    /// Coalesced collection view item updates.
    public func coalescedCollectionViewItems() {
        collectionViewUpdateSource?.add(data: 1)
    }
    
}

// MARK: - Collection view data source
extension PostDetailsDataSource: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1                                /* post details */
               + (albumSections?.count ?? 0)    /* albums */
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // post details
        guard section > 0 else {
            return 0
        }
        
        // albums
        let albumIndex = self.albumIndex(for: section)
        guard let albums = post?.user?.albums, albumIndex < albums.count,
            let sections = self.albumSections, albumIndex < sections.count else {
            return 0
        }
        
        // section is collpased?
        return sections[albumIndex].isCollapsed ? 0 : albums[albumIndex].photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // create cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostAlbumCollectionViewCell.viewIdentifier, for: indexPath)
        
        // set model
        guard let photoCell = cell as? PostAlbumCollectionViewCell,
            let photo = photo(for: indexPath) else {
            return cell
        }
        let title = photo.title
        let imageUrl = photo.thumbnailUrl
        let image = photoController.photo(for: imageUrl)
        photoCell.model = PostAlbumCollectionViewCell.Model(identifier: photo.id, title: title, photo: image)
        photoCell.delegate = self
        
        // no photo yet? -> fetch
        if image == nil, let imageUrl = imageUrl {
            photoController.fetchPhotos(from: [imageUrl]) { [weak self] _, image in
                guard photoCell.model?.photo == nil else { return }
                
                // queue a cell's model refresh
                photoCell.model = PostAlbumCollectionViewCell.Model(identifier: photo.id, title: title, photo: image)
                self?.coalescedCollectionViewItems()
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        // create header
        let viewIdentifier = indexPath.section == 0 ? PostDetailsHeaderView.viewIdentifier : PostAlbumHeaderView.viewIdentifier
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: viewIdentifier, for: indexPath)

        // a) post details
        if let view = headerView as? PostDetailsHeaderView, let post = self.post {
            view.model = PostDetailsHeaderView.Model(post: post)
        }

        // b) album title
        else if let view = headerView as? PostAlbumHeaderView, let albumSections = self.albumSections {
            let albumIndex = self.albumIndex(for: indexPath.section)
            view.configure(with: albumSections[albumIndex].title,
                           isCollapsed: albumSections[albumIndex].isCollapsed,
                           section: indexPath.section,
                           collectionView: collectionView,
                           delegate: self)
        }

        return headerView
    }
    
    /// Get the photo (model object `Photo`) associated with the given index path.
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
    
    /// Get the album index from a section index.
    ///
    /// - Parameter section: The section index.
    /// - Returns: The corresponding album index.
    func albumIndex(for section: Int) -> Int {
        return section - 1
    }
    
}


// MARK: - Prefetching data source
// Requirement #11: ✅ (pre-fetching protocol)
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
        if section == 0 {
            // post details
            if let postDetailsView = postDetailsView(from: collectionView) {
                // calculate fitting height after laying out with model data
                if let post = self.post {
                    postDetailsView.model = PostDetailsHeaderView.Model(post: post)
                }
                return postDetailsView.systemLayoutSizeFitting(collectionView.bounds.size,
                                                               withHorizontalFittingPriority: .required,
                                                               verticalFittingPriority: .defaultLow)
            }
            return CGSize(width: collectionView.frame.width, height: 250)
        }
            
        else {
            // album title
            return CGSize(width: collectionView.frame.width, height: PostAlbumHeaderView.headerHeight)
        }
    }
    
    /// Get the post details view (supplementary view) on screen, or dequeue one if needed.
    ///
    /// - Returns: The post details view.
    private func postDetailsView(from collectionView: UICollectionView) -> PostDetailsHeaderView? {
        // check if is on screen
        if let view = (collectionView.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader).first { $0 is PostDetailsHeaderView}) as? PostDetailsHeaderView {
            return view
        }
        else {
            // otherwise dequeue one
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: PostDetailsHeaderView.viewIdentifier, for: IndexPath(row: 0, section: 0)) as? PostDetailsHeaderView
            return view
        }
    }
    
}


// MARK: - Collection view delegate
extension PostDetailsDataSource: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        coalescedCollectionViewItems()
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        coalescedCollectionViewItems()
    }
}


// MARK: - PostAlbumHeaderViewDelegate delegate
extension PostDetailsDataSource: PostAlbumHeaderViewDelegate {
    
    func tableView(collectionView: UICollectionView?, headerTapped: PostAlbumHeaderView, section: Int?) {
        guard let section = section else { return }
        let albumIndex = self.albumIndex(for: section)
        
        // toggle collapsed state
        let currentIsCollapsed = albumSections?[albumIndex].isCollapsed ?? true
        albumSections?[albumIndex].isCollapsed = !currentIsCollapsed
        headerTapped.isCollapsed = !currentIsCollapsed
        
        // reload section
        collectionView?.reloadSections(IndexSet(integer: section))
    }
    
}


// MARK: - PostAlbumCollectionViewCellDelegate delegate
extension PostDetailsDataSource: PostAlbumCollectionViewCellDelegate {
    
    func photoTapped(on cell: PostAlbumCollectionViewCell) {
        if let photoId = cell.model?.identifier {
            coordinator?.showFullscreenPhoto(with: photoId)
        }
    }
    
}
