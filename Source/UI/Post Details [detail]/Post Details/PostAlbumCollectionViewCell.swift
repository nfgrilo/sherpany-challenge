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
            
            // update UI
            title.text = model.title
            photo.backgroundColor = isLoading ? UIColor(white: 0.98, alpha: 1) : .clear
            photo.image = model.photo
            photo.isHidden = isLoading
            if !isLoading && activityIndicator.isAnimating {
                activityIndicator.stopAnimating()
                photo.isHidden = false
            }
            
            // update photo size constraints.
            // this will also limit the total cell width.
            photoWidthConstraint?.constant = model.photo?.size.width ?? 150
            photoWidthConstraint?.priority = .defaultHigh
            photoWidthConstraint?.isActive = true
            photoHeightConstraint?.constant = model.photo?.size.height ?? 150
            photoHeightConstraint?.priority = .defaultHigh
            photoHeightConstraint?.isActive = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        showActivityIndicator()
    }

    /// Set up cell.
    private func setup() {
        // use autolayout
        contentView.translatesAutoresizingMaskIntoConstraints = false
        photoWidthConstraint = photo.widthAnchor.constraint(equalToConstant: 0)
        photoHeightConstraint = photo.heightAnchor.constraint(equalToConstant: 0)
        
        // setup photo
        photo.layer.masksToBounds = true
        photo.layer.cornerRadius = 8
        
        // activity indicator
        showActivityIndicator()
        
        // add tap gesture
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photoTapped(_:))))
    }
    
    /// Show the activity indicator.
    private func showActivityIndicator() {
        guard model?.photo == nil else { return }
        
        photo.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
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
