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
    
    /// Cell delegate.
    weak var delegate: PostAlbumTableViewCellDelegate?
    
    /// View-model.
    var model: Model? {
        didSet {
            // let delegate know the model has just been set
            delegate?.didSetModel(model)
        }
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        // call delegate to get optimal content view size
        return delegate?.contentViewSizeFitting(targetSize) ?? .zero
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
            self.photosUrl = photos.compactMap { $0.thumbnailUrl }
            self.titles = photos.compactMap { $0.title }
        }
    }
}


/// Album table view cell delegate.
protocol PostAlbumTableViewCellDelegate: class {
    
    /// Called when the cell model is set.
    ///
    /// - Parameter model: The cell model.
    func didSetModel(_ model: PostAlbumTableViewCell.Model?)
    
    
    /// Called to calculate optimal size of the content view.
    ///
    /// - Parameter targetSize: The size that you prefer for the view.
    /// - Returns: The optimal size for the view.
    func contentViewSizeFitting(_ targetSize: CGSize) -> CGSize
    
}
