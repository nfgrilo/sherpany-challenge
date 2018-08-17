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
    
    /// Post albums.
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    
    /// View-model.
    var model: Model?
    
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
