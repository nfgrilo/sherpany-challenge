//
//  FullscreenPhotoViewController.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 23/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

protocol FullscreenPhotoViewControllerDelegate: class {
    /// Called when user taps on photo.
    func photoTapped()
}

class FullscreenPhotoViewController: UIViewController, Storyboarded {
    
    /// Photo.
    @IBOutlet weak var photo: UIImageView!
    
    /// Loading indicator.
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /// The delegate to be informed when the photo is tapped.
    weak var delegate: FullscreenPhotoViewControllerDelegate?
    
    
    /// View-model.
    var model: Model? {
        didSet {
            guard let model = model else {
                return
            }
            
            // update image
            photo.image = model.photo
            
            // hide activity indicator if full image loaded
            // Requirement #12: ✅ (UI feedback)
            if !model.isThumbnail {
                activityIndicator.stopAnimating()
            }
            
            /// navigation title
            if let imageTitle = model.title {
                title = imageTitle
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    /// Initial setup.
    private func setup() {
        // add tap gesture
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photoTapped(_:))))
    }
    
    /// Called when user taps header.
    ///
    /// - Parameter gestureRecognizer: The associated gesture recognizer.
    @objc func photoTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.photoTapped()
    }
    
}


/// View-model.
extension FullscreenPhotoViewController {
    struct Model {
        let photo: UIImage?
        let isThumbnail: Bool
        let title: String?
        
        init(image: UIImage?, isThumbnail: Bool = false, title: String? = nil) {
            self.photo = image
            self.isThumbnail = isThumbnail
            self.title = title
        }
    }
}
