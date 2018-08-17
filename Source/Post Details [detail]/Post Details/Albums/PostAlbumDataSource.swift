//
//  PostAlbumDataSource.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 17/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostAlbumDataSource: NSObject, UICollectionViewDataSource {
    
    /// Alias for data source model
    typealias Model = PostAlbumTableViewCell.Model
    
    /// Collection view model (photos).
    var model: Model?
    
    /// Photo cell identifier.
    private let photoCellIdentifier = "PhotoCellId"
    
    
    // MARK: - Collection data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.photos.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // create cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath)
        
        // set model
        let index = indexPath.row
        if let photoCell = cell as? PostAlbumCollectionViewCell,
            index < model?.photos.count ?? 0 && index < model?.titles.count ?? 0,
            let photo = model?.photos[indexPath.row] {
            let title = model?.titles[indexPath.row]
            photoCell.model = PostAlbumCollectionViewCell.Model(title: title, photo: photo)
        }
        
        return cell
    }
    
}
