//
//  PostAlbumDataSource.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 17/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostAlbumDataSource: NSObject {
    
    /// Photo controller.
    private let photoController: PhotoController
    
    /// Alias for data source model
    typealias Model = PostAlbumTableViewCell.Model
    
    /// Collection view model (photos).
    var model: Model?
    
    /// Photo cell identifier.
    private let photoCellIdentifier = "PhotoCellId"
    
    
    /// Initializes the data source.
    ///
    /// - Parameter photoController: The shared photo controller.
    init(photoController: PhotoController) {
        self.photoController = photoController
        super.init()
    }
    
}


// MARK: - Collection data source
extension PostAlbumDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // create cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath)
        
        // set model
        let index = indexPath.row
        if let photoCell = cell as? PostAlbumCollectionViewCell,
            index < model?.count ?? 0,
            let photoUrl = model?.photosUrl[index] {
            let photo = photoController.photo(for: photoUrl)
            let title = model?.titles[indexPath.row]
            photoCell.model = PostAlbumCollectionViewCell.Model(title: title, photo: photo)
            
            // no photo yet? -> fetch
            if photo == nil {
                print("cellForItemAt: Fetching \(indexPath)")
                
                photoController.fetchPhoto(from: photoUrl) { image in
                    DispatchQueue.main.async {
                        print("  -> 🙏🏻 Fetched for cellForItem: \(indexPath)")
                        // update cell's model (without animation)
                        photoCell.model = PostAlbumCollectionViewCell.Model(title: title, photo: photo)
                        CATransaction.begin()
                        CATransaction.setDisableActions(true)
                        collectionView.reloadItems(at: [indexPath])
                        CATransaction.commit()

                        // layout on next runloop
                        DispatchQueue.main.async {
                            collectionView.setNeedsLayout()
                            collectionView.layoutIfNeeded()
                        }
                    }
                }
                
                
            }
        }
        
        return cell
    }
    
}


// MARK: - Prefetching data source
extension PostAlbumDataSource: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // FIXME: not called
        print("PRE-FETCHING: \(indexPaths)")
        guard let model = self.model else { return }
        
        for indexPath in indexPaths {
            // asynchronously fetch photo
            if indexPath.row < model.count {
                let photoUrl = model.photosUrl[indexPath.row]
                photoController.fetchPhoto(from: photoUrl)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        // FIXME: not called
        print("CANCELLING PRE-FETCH")
        guard let model = self.model else { return }
        
        for indexPath in indexPaths {
            // cancel any current photo requests
            if indexPath.row < model.count {
                let photoUrl = model.photosUrl[indexPath.row]
                photoController.cancelPhotoFetch(url: photoUrl)
            }
        }
    }
    
}
