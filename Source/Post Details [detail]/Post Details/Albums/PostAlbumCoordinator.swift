//
//  PostAlbumCoordinator.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 20/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostAlbumCoordinator: Coordinator {
    /// Child coordinators.
    var childCoordinators: [Coordinator] = []
    
    /// The parent table view cell.
    var cell: UITableViewCell
    
    /// Model controller.
    private let modelController: ModelController
    
    /// Post Albums collection view controller
    var albumViewController: PostAlbumCollectionViewController?
    
    /// Post Albums collection view data source
    var albumViewDataSource: PostAlbumDataSource?
    
    
    /// Creates a coordinator.
    ///
    /// - Parameter navigationController: The root view controller "BOSSed" by this coordinator.
    init(cell: UITableViewCell, modelController: ModelController) {
        self.cell = cell
        self.modelController = modelController
    }
    
    /// Take control!
    func start() {
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
        cell.contentView.addSubview(collectionView)
        let views: [String: Any] = ["photos": collectionView]
        let options: NSLayoutFormatOptions = .init(rawValue: 0)
        cell.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[photos]|", options: options, metrics: nil, views: views))
        cell.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[photos]|", options: options, metrics: nil, views: views))
    }
    
    
}

// MARK: - Post (single) album delegate

extension PostAlbumCoordinator: PostAlbumTableViewCellDelegate {
    
    func didSetModel(_ model: PostAlbumTableViewCell.Model?) {
        // update collection view
        albumViewDataSource?.model = model
        albumViewController?.view.isHidden = (model == nil)
        
        // layout collection view on table's view cell
        guard let collectionView = albumViewController?.collectionView else { return }
        //  -> layout this cell's contents (to get width)
        cell.contentView.layoutIfNeeded()
        //  -> load collection view photos
        collectionView.reloadData()
        //  -> trigger collection view layout on this runloop
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
    }
    
    func contentViewSizeFitting(_ targetSize: CGSize) -> CGSize {
        guard let collectionView = albumViewController?.collectionView else { return .zero }
        
        // autolayout is enabled on collection view's cells (with `.estimatedItemSize`)
        //  => force collection view relayout with the given width
        collectionView.frame = CGRect(x: 0, y: 0, width: targetSize.width, height: 1)
        collectionView.layoutIfNeeded()
        
        var collectionViewSize = collectionView.collectionViewLayout.collectionViewContentSize
        collectionViewSize.height += 40 // add bottom padding
        return collectionViewSize
    }
    
}
