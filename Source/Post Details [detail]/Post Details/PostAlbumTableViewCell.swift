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
    
    /// View-model.
    var model: Model? {
        didSet {
            albumViewDataSource?.model = model
            albumViewController?.view.isHidden = (model == nil)
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
        let dataSource = PostAlbumDataSource()
        self.albumViewDataSource = dataSource
        collectionView.dataSource = dataSource
        
        // add photos collection view to view hierarchy
        contentView.addSubview(collectionView)
        let views: [String: Any] = ["photos": collectionView]
        let options: NSLayoutFormatOptions = .init(rawValue: 0)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[photos]|", options: options, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[photos]|", options: options, metrics: nil, views: views))
    }
    
}


/// Album table view cell view-model.
extension PostAlbumTableViewCell {
    struct Model {
        let photos: [UIImage]
        let titles: [String]
        
        init(photos: [Photo]) {
            self.photos = []
            self.titles = []
        }
    }
}
