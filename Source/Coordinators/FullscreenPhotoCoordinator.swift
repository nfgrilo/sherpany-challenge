//
//  FullscreenPhotoCoordinator.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 23/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class FullscreenPhotoCoordinator: Coordinator {
    
    /// The navigation view controller currently being used to present view controllers.
    var navigationController: UINavigationController
    
    /// The view controller.
    var viewController: FullscreenPhotoViewController?
    
    /// Photo controller.
    private let photoController: PhotoController
    
    /// The Photo .
    private var photo: Photo
    
 
    // MARK: - Coordinator setup
    
    /// Creates a coordinator.
    ///
    /// - Parameter navigationController: The root view controller "BOSSed" by this coordinator.
    init(navigationController: UINavigationController, photoController: PhotoController, photo: Photo) {
        self.navigationController = navigationController
        self.photoController = photoController
        self.photo = photo
    }
    
    /// Take control!
    override func start() {
        // view controller
        guard let viewController = FullscreenPhotoViewController.instantiate() else { return }
        viewController.delegate = self
        self.viewController = viewController
        
        // model
        DispatchQueue.main.async { [weak self] in
            guard let photo = self?.photo,
                let photoUrl = photo.url,
                let photoController = self?.photoController else {
                self?.navigationController.popViewController(animated: true)
                return
            }
            
            // set photo
            if let bigImage = photoController.photo(for: photo.url) {
                // full image
                viewController.model = FullscreenPhotoViewController.Model(photo: bigImage, isThumbnail: false)
            }
            else {
                if let thumbnail = photoController.photo(for: photo.thumbnailUrl) {
                    // thumbnail
                    viewController.model = FullscreenPhotoViewController.Model(photo: thumbnail, isThumbnail: true)
                }
                else {
                    viewController.activityIndicator.color = .darkGray
                }
                
                // fetch photo & update
                photoController.fetchPhotos(from: [photoUrl]) { [weak self] url, image in
                    self?.viewController?.model = FullscreenPhotoViewController.Model(photo: image, isThumbnail: false)
                }
            }
        
            // present it
            self?.navigationController.pushViewController(viewController, animated: true)
        }
    }
    
}

extension FullscreenPhotoCoordinator: FullscreenPhotoViewControllerDelegate {
    
    func photoTapped() {
        navigationController.popViewController(animated: true)
    }
    
}
