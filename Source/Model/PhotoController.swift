//
//  PhotoController.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 21/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PhotoController {
    
    /// Serial queue for queueing requests, locking access to `fetchImage`.
    private let serviceQueue = DispatchQueue(label: "PhotoController Serial Queue")
    
    /// Concurrent queue for network requests.
    private let networkQueue = DispatchQueue(label: "PhotoController Concurrent Queue", qos: .background, attributes: .concurrent)
    
    /// Image memory cache holding already fetched images.
    private let cache: NSCache<NSString,UIImage> = NSCache()
    
    /// Alias for task copmletion closure.
    typealias TaskCompletion = (UIImage?) -> Void
    
    /// Completion closures to be called when a photo with specified id has been fetched.
    private var completionClosures: [URL: [TaskCompletion]] = [:]
    
    /// Dispatch work items fetching associated url.
    private var workItems: [URL: DispatchWorkItem] = [:]
    
    
    /// Initialize the controller.
    init() {
        // cache 100 photos at most
        cache.countLimit = 100
        
        // clean up cache on low memory
        NotificationCenter.default.addObserver(self, selector: #selector(cleanCache), name: .UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    
    // MARK: - Photo
    
    /// Gets a photo from cache.
    ///
    /// - Parameter url: The photo URL.
    /// - Returns: Returns the cache image, if any.
    func photo(for url: URL) -> UIImage? {
        return cache.object(forKey: url.absoluteString as NSString)
    }
    
    /// Fetch a photo from the network.
    ///
    /// - Parameters:
    ///   - url: The photo URL.
    ///   - completion: The closure to be called when complete.
    func fetchPhoto(from url: URL, completion: TaskCompletion? = nil) {
        serviceQueue.sync { [weak self] in
            // add to completion closures for this url
            if let completion = completion {
                self?.addToCompletionClosure(url: url, completion: completion)
            }
            
            // if image is already cached, return it
            if let cachedPhoto = photo(for: url) {
                self?.notifyCompletionClosures(for: url, with: cachedPhoto)
                return
            }
            
            // otherwise, fetch image & notify "observers"
            let workItem = DispatchWorkItem() {
                self?.networkFetch(url: url) { image in
                    // call completions
                    self?.serviceQueue.sync {
                        self?.notifyCompletionClosures(for: url, with: image)
                    }
                }
            }
            workItems[url] = workItem
            networkQueue.async(execute: workItem)
        }
    }
    
    /// Cancel an ongoing network request.
    ///
    /// - Parameter url: The url being fetched to cancel.
    func cancelPhotoFetch(url: URL) {
        // cancel ongoing photo fetch
        let workItem = workItems[url]
        workItem?.cancel()
        workItems.removeValue(forKey: url)
        
        // clean completion closures
        completionClosures.removeValue(forKey: url)
    }
    
    
    // MARK: - Network
    
    /// Fetch an image from the network.
    ///
    /// - Parameters:
    ///   - url: The image url
    ///   - completion: The completion closure to be called when complete.
    private func networkFetch(url: URL, completion: TaskCompletion? = nil) {
        // make sure task was not cancelled
        guard let workItem = workItems[url], !workItem.isCancelled else {
            completion?(nil)
            return
        }
        
        // fetch image
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let data = data else {
                completion?(nil)
                return
            }
            completion?(UIImage(data: data))
        })
        task.resume()
    }
    
    
    // MARK: - Completion closures
    
    /// Add a completion closure for a given URL.
    ///
    /// - Parameters:
    ///   - url: The image url.
    ///   - completion: The completion closure to be called when fetch request for the URL completes.
    private func addToCompletionClosure(url: URL, completion: @escaping TaskCompletion) {
        // add to completion closure list for that url
        var completions = completionClosures[url] ?? []
        completions.append(completion)
        completionClosures[url] = completions
    }
    
    /// Notify observers (registered copmletion closures) of a fetched image from the network.
    ///
    /// - Parameters:
    ///   - url: The url the image was fetched from.
    ///   - image: The fetched image.
    private func notifyCompletionClosures(for url: URL, with image: UIImage?) {
        // cache photo
        if let photo = image {
            cache.setObject(photo, forKey: url.absoluteString as NSString)
        }
        
        // notify
        for closure in completionClosures[url] ?? [] {
            closure(image)
        }
        
        // clean completion closures array
        completionClosures.removeValue(forKey: url)
        
        // clean work item
        workItems.removeValue(forKey: url)
    }
    
    
    // MARK: - Cache
    
    /// Wipes all the image cache.
    @objc func cleanCache() {
        print("Cleaning photo cache...")
        cache.removeAllObjects()
    }
    
}
