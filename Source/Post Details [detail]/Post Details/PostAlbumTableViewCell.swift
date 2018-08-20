//
//  PostAlbumTableViewCell.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 16/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

// Requirement #10: ✅ (album photos)

class PostAlbumTableViewCell: UITableViewCell {
    
    /// Post Albums collection view controller
    var albumViewController: PostAlbumCollectionViewController?
    
    /// Post Albums collection view data source
    var albumViewDataSource: PostAlbumDataSource?
    
    /// Post Album height constraint.
    var albumViewHeightConstraint: NSLayoutConstraint?
    
    /// View-model.
    var model: Model? {
        didSet {
            // update collection view
            albumViewDataSource?.model = model
            albumViewController?.view.isHidden = (model == nil)
            
            // layout collection view on table's view cell
            guard let collectionView = albumViewController?.collectionView else { return }
            //  -> layout this cell's contents (to get width)
            contentView.layoutIfNeeded()
            //  -> load collection view photos
            collectionView.reloadData()
            //  -> trigger collection view layout on this runloop
            collectionView.setNeedsLayout()
            collectionView.layoutIfNeeded()
        }
    }
    
    /// IB initialization.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /// Add collection view to cell content view.
    private func setup() {
        // photos collection view controller
        guard let viewController = PostAlbumCollectionViewController.instantiate() else { return }
        self.albumViewController = viewController
        
        // setup photos collection view
        guard let collectionView = viewController.collectionView else { return }
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        let dataSource = PostAlbumDataSource()
        self.albumViewDataSource = dataSource
        collectionView.dataSource = dataSource
        collectionView.prefetchDataSource = dataSource
        collectionView.delegate = dataSource
        // custom flow layout that top-align photos
        let flowLayout = PostAlbumCollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 1, height: 1) // enable dynamic cell sizing
        collectionView.collectionViewLayout = flowLayout
        
        // add photos collection view to view hierarchy
        contentView.addSubview(collectionView)
        let views: [String: Any] = ["photos": collectionView]
        let options: NSLayoutFormatOptions = .init(rawValue: 0)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[photos]|", options: options, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[photos]|", options: options, metrics: nil, views: views))
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        guard let collectionView = albumViewController?.collectionView else { return .zero }
        
        // autolayout is enabled on collection view's cells (with `.estimatedItemSize`)
        //  => force collection view relayout with the given width
        collectionView.frame = CGRect(x: 0, y: 0, width: targetSize.width, height: 1)
        collectionView.layoutIfNeeded()
        
        return collectionView.collectionViewLayout.collectionViewContentSize
    }
}


/// Album table view cell view-model.
extension PostAlbumTableViewCell {
    struct Model {
        let photosUrl: [URL]
        let titles: [String]
        
        var count: Int {
            return min(photosUrl.count, titles.count)
        }
        
        init(photos: [Photo]) {
            self.photosUrl = photos.compactMap { $0.url }
            self.titles = photos.compactMap { $0.title }
        }
    }
}
