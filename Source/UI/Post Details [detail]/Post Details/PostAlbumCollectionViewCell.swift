//
//  PostAlbumCollectionViewCell.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 17/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

protocol PostAlbumCollectionViewCellDelegate {
    /// Called when user taps on photo.
    func photoTapped(on cell: PostAlbumCollectionViewCell)
}

class PostAlbumCollectionViewCell: UICollectionViewCell {
    
    /// Reusable view identifier.
    static let viewIdentifier = "PostAlbumCollectionViewCell"
    
    /// Default thumbnail size (definitive size will be copmuted when model is set).
    static let defaultThumbnailSize = CGSize(width: 150, height: 150)
    
    /// Photo title.
    @IBOutlet weak var title: UILabel!
    
    /// Photo.
    @IBOutlet weak var photo: UIImageView!
    
    /// Loading indicator.
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /// Cell width constraint.
    var photoWidthConstraint: NSLayoutConstraint?
    
    /// Cell height constraint.
    var photoHeightConstraint: NSLayoutConstraint?
    
    /// The delegate to be informed when the photo is tapped.
    var delegate: PostAlbumCollectionViewCellDelegate?
    
    /// View-model.
    var model: Model? {
        didSet {
            guard let model = model else {
                return
            }
            
            let isLoading = model.photo == nil
            
            // update photo & title
            title.text = model.title
            photo.image = model.photo
            
            // show/hide activity indicator
            // Requirement #12: ✅ (UI feedback)
            if !isLoading {
                activityIndicator.stopAnimating()
                photo.setNeedsDisplay()
            }
            else {
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
            }
            
            // update photo size constraints.
            // this will also limit the total cell width.
            photoWidthConstraint?.constant = model.photo?.size.width ?? PostAlbumCollectionViewCell.defaultThumbnailSize.width
            photoWidthConstraint?.priority = .defaultHigh
            photoWidthConstraint?.isActive = true
            photoHeightConstraint?.constant = model.photo?.size.height ?? PostAlbumCollectionViewCell.defaultThumbnailSize.height
            photoHeightConstraint?.priority = .defaultHigh
            photoHeightConstraint?.isActive = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    /// Set up cell.
    private func setup() {
        // use autolayout
        contentView.translatesAutoresizingMaskIntoConstraints = false
        photoWidthConstraint = photo.widthAnchor.constraint(equalToConstant: PostAlbumCollectionViewCell.defaultThumbnailSize.width)
        photoHeightConstraint = photo.heightAnchor.constraint(equalToConstant: PostAlbumCollectionViewCell.defaultThumbnailSize.height)
        
        // add tap gesture
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photoTapped(_:))))
    }
    
    /// Called when user taps header.
    ///
    /// - Parameter gestureRecognizer: The associated gesture recognizer.
    @objc func photoTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.photoTapped(on: self)
    }
    
}


/// Posts Album collection view cell view-model.
extension PostAlbumCollectionViewCell {
    struct Model {
        let identifier: Int64
        let title: String
        let photo: UIImage?
        
        init(identifier: Int64, title: String?, photo: UIImage?) {
            self.identifier = identifier
            self.title = title ?? "(untitled photo)"
            self.photo = photo
        }
    }
}
