//
//  PhotoStorageController.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 17/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PhotoStorageController {
    
    /// Get a photo from local storage by its `id`.
    ///
    /// - Parameter photoId: The photo `id`.
    /// - Returns: An image, if the found on storage.
    func photo(for photoId: Int64) -> UIImage? {
        guard let photoURL = self.photoURL(for: photoId),
            let image = UIImage(contentsOfFile: photoURL.path) else {
                return nil
        }
        return image
    }
    
    /// Removes all photos from the filesystem.
    func removeAllPhotos() {
        print("Removing all stored photos...")
        guard let url = photosDirectoryURL else { return }
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(error)
        }
    }
    
    /// Locally stores a photo by its photo `id`.
    ///
    /// - Parameters:
    ///   - photo: The image to be stored.
    ///   - id: The image `id`.
    func storePhoto(_ photo: UIImage, with id: Int64) {
        guard let photoURL = self.photoURL(for: id) else { return }
        let imageData = UIImageJPEGRepresentation(photo, 1.0)
        
        do {
            try imageData?.write(to: photoURL)
        } catch {
            print(error)
        }
    }
    
    
    // MARK: - Private methods
    
    /// Photos location on filesystem.
    private var photosDirectoryURL: URL? {
        let fm = FileManager.default
        var photosDirectory: URL?
        do {
            let documentDirectory = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
            let photosDir = documentDirectory.appendingPathComponent("Photos", isDirectory: true)
            try fm.createDirectory(at: photosDir, withIntermediateDirectories: true, attributes: nil)
            photosDirectory = photosDir
        } catch {
            print(error)
        }
        return photosDirectory
    }
    
    /// Get the local URL for a photo, given its id`.
    ///
    /// - Parameter photoID: The photo id.
    /// - Returns: An URL for the locally stored photo.
    private func photoURL(for photoId: Int64) -> URL? {
        let filename = String(photoId)
        return photosDirectoryURL?.appendingPathComponent(filename)
    }
    
}
