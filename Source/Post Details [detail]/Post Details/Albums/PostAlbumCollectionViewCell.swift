//
//  PostAlbumCollectionViewCell.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 17/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostAlbumCollectionViewCell: UICollectionViewCell {
    
    /// Photo title.
    @IBOutlet weak var title: UILabel!
    
    /// Photo.
    @IBOutlet weak var photo: UIImageView!
    
    /// Cell width constraint.
    var widthConstraint: NSLayoutConstraint?
    
    /// View-model.
    var model: Model? {
        didSet {
            guard let model = model else {
                return
            }
            
            // update UI
            title.text = model.title
            photo.image = model.photo
            
            // force width to image width + leading & trailing space
            widthConstraint?.constant = 20 + model.photo.size.width + 20
            widthConstraint?.isActive = true
        }
    }
    
    /// IB initialization.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    /// Set up cell.
    private func setup() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        widthConstraint = contentView.widthAnchor.constraint(equalToConstant: 1)
    }
    
}


/// Posts Album collection view cell view-model.
extension PostAlbumCollectionViewCell {
    struct Model {
        let title: String
        let photo: UIImage
        
        init(title: String?, photo: UIImage) {
            self.title = title ?? "(untitled photo)"
            self.photo = photo
        }
    }
}
