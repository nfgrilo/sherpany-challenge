//
//  PhotoController.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 21/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PhotoController {
    
    /// Alias for task completion closure.
    typealias TaskCompletion = (URL?, UIImage?) -> Void
    
    /// A photo network fetch object.
    class Task: Hashable {
        let url: URL
        var completions: [TaskCompletion] = []
        var workItem: DispatchWorkItem?
        var dataTask: URLSessionDataTask?
        private(set) var isCancelled: Bool
        
        init(url: URL, completions: [TaskCompletion]) {
            self.url = url
            self.completions = completions
            self.isCancelled = false
        }
        
        /// Cancel the task.
        func cancel() {
            dataTask?.cancel()
            workItem?.cancel()
            completions.removeAll()
            isCancelled = true
        }
        
        static func == (lhs: PhotoController.Task, rhs: PhotoController.Task) -> Bool {
            return lhs.url == rhs.url
        }

        var hashValue: Int {
            return url.hashValue
        }
    }
    
    /// Queue of tasks (LIFO).
    private var tasks: [Task] = []
    
    /// (Strong refernce to) Tasks being executed (LIFO).
    private var executingTasks: [Task] = []
    
    
    /// Initialize the controller.
    init() {
        // limit number of cached photos
        cache.countLimit = 1000
        
        // clean up cache on low memory
        NotificationCenter.default.addObserver(self, selector: #selector(cleanCache), name: .UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    
    // MARK: - Photos
    
    /// Gets a photo from cache.
    /// If `nil` need to call `fetchPhoto(from:completion:)`.
    ///
    /// - Parameter url: The photo URL.
    /// - Returns: Returns the cache image, if any.
    func photo(for url: URL?) -> UIImage? {
        guard let url = url else { return nil }
        return cache.object(forKey: url.absoluteString as NSString)
    }
    
    /// Image memory cache holding already fetched images.
    private let cache: NSCache<NSString,UIImage> = NSCache()
    
    /// Wipes all the image cache.
    @objc func cleanCache() {
        print("⚠️ Cleaning photo cache...")
        cache.removeAllObjects()
    }
    
    /// Fetch and cache photos from the network.
    ///
    /// - Parameters:
    ///   - urls: The photo URLs.
    ///   - completion: The closure to be called when complete.
    func fetchPhotos(from urls: [URL], completion: TaskCompletion? = nil) {
        var newTasks: [Task] = []
        for url in urls {
            // photo already cached?
            if let cachedPhoto = photo(for: url) {
                completion?(url, cachedPhoto)
                continue
            }
            
            // get/create task
            guard let task = self.task(for: url, createIfInexistent: true, addCompletion: completion) else {
                completion?(url, nil)
                continue
            }
            if task.workItem == nil {
                // define task work item (fetch image & notify "observers")
                task.workItem = DispatchWorkItem() { [weak self, weak task] in
                    self?.networkFetch(task) { _, image in
                        self?.finishTask(task, image: image)
                    }
                }
            }
            
            newTasks.append(task)
        }
        
        // queue tasks
        enqueueTasks(newTasks)
    }
    
    /// Lower priority for a network request.
    ///
    /// - Parameter urls: The urls being fetched to slow down.
    func slowdownPhotoFetches(urls: [URL]) {
        // lower task priority task
        lowerTaskPriority(for: urls)
    }
    
    /// Cancel all pending or ongoing network requests.
    func cancelAllPhotoFetchs() {
        cancelAllTasks()
    }
    
    
    // MARK: - Tasks
    
    private func task(for url: URL, createIfInexistent: Bool = false, addCompletion completion: TaskCompletion? = nil) -> Task? {
        var task: Task?
        
        // search for existing task
        for existingTask in tasks.reversed() {
            if url == existingTask.url {
                task = existingTask
                break
            }
        }
        
        // set task completions
        var completions: [TaskCompletion] = task?.completions ?? []
        if let completion = completion {
            completions.append(completion)
            task?.completions = completions
        }
        
        // create new task (?)
        if task == nil && createIfInexistent {
            task = Task(url: url, completions: completions)
        }
        
        return task
    }
    
    /// Enqueue tasks.
    /// Task will run asynchronously and the number of simultaneous tasks is limited.
    ///
    /// - Parameter tasks: The tasks to queue.
    private func enqueueTasks(_ tasks: [Task]) {
        // run atomically, to lock access to  `tasks`
        serviceQueue.async { [weak self] in
            // queue tasks
            for task in tasks {
                if let existingIndex = self?.tasks.index(of: task) {
                    // increase priority by removing and (re)appending
                    self?.tasks.remove(at: existingIndex)
                }
            }
            self?.tasks.append(contentsOf: tasks)
            
            // execute next task
            if self?.executingTasks.count ?? 0 < PhotoController.maxConcurrentDownloads {
                self?.executeNextTask()
            }
        }
    }
    
    /// Dequeues and executes next task.
    private func executeNextTask() {
        dequeueTask { [weak self] task in
            guard let task = task else { return }
            self?.networkQueue.async {
                task.workItem?.perform()
            }
        }
    }
    
    /// Dequeue most recently queued task.
    ///
    /// - Parameter completion: The dequeued task.
    private func dequeueTask(completion: @escaping (Task?) -> ()) {
        // run atomically, to lock access to  `tasks`
        serviceQueue.async { [weak self] in
            guard let tasks = self?.tasks  else {
                completion(nil)
                return
            }

            // get last non-cancelled task
            while !tasks.isEmpty {
                // pick up task in middle
                let index = tasks.count / 2
                
                if let task = index < tasks.count ? tasks[index] : tasks.last, !task.isCancelled {
                    // add strong ref to `executingTasks`
                    self?.executingTasks.append(task)
                    
                    // remove from `tasks`
                    if let taskIndex = tasks.index(of: task) {
                        self?.tasks.remove(at: taskIndex)
                    }

                    // call completion with task
                    completion(task)
                    return
                }
            }

            completion(nil)
        }
    }
    
    /// Lower task priority for the given urls.
    ///
    /// - Parameter urls: The tasks urls.
    private func lowerTaskPriority(for urls: [URL]) {
        // run atomically, to lock access to  `tasks`
        serviceQueue.async { [weak self] in
            for url in urls {
                // get task
                guard let task = self?.task(for: url) else { continue }

                // move to the end of queue (1st position)
                if let existingIndex = self?.tasks.index(of: task) {
                    self?.tasks.remove(at: existingIndex)
                }
                self?.tasks.insert(task, at: 0)
            }
        }
    }
    
    /// Cancel all tasks.
    private func cancelAllTasks() {
        // run atomically, to lock access to  `tasks`
        serviceQueue.async { [weak self] in
            // cancel all tasks
            self?.tasks.forEach { $0.cancel() }
            self?.executingTasks.removeAll()

            // remove all from queue
            self?.tasks.removeAll()
        }
    }
    
    /// Finish task and notify observers (registered completion closures) of a fetched image from the network.
    ///
    /// - Parameters:
    ///   - task: The task.
    ///   - image: The fetched image.
    private func finishTask(_ task: Task?, image: UIImage?) {
        guard let task = task else { return }
        
        // cache photo
        if let photo = image {
            cache.setObject(photo, forKey: task.url.absoluteString as NSString)
        }
        
        // task
        guard !task.isCancelled else {
            return
        }
        
        // notify
        DispatchQueue.main.async {
            task.completions.forEach { $0(task.url, image) }
        }
        
        // clean
        // run atomically, to lock access to `tasks`
        serviceQueue.async { [weak self] in
            if let existingIndex = self?.tasks.index(of: task) {
                self?.tasks.remove(at: existingIndex)
            }
            if let existingIndex = self?.executingTasks.index(of: task) {
                self?.executingTasks.remove(at: existingIndex)
            }

            print("Finished task \(task.url) (#tasks: \(self?.tasks.count ?? -1), #executing: \(self?.executingTasks.count ?? -1)")
        }
        
        // execute next task
        executeNextTask()
    }
    
    /// Serial queue for queueing photo requests.
    private let serviceQueue = DispatchQueue(label: "PhotoController Serial Queue")
    
    /// Concurrent queue for network requests.
    private let networkQueue = DispatchQueue(label: "PhotoController Network Queue", qos: .background, attributes: .concurrent)
    
    
    // MARK: - Network access
    
    /// Fetch an image from the network.
    ///
    /// - Parameters:
    ///   - task: The task.
    ///   - completion: The completion closure to be called when complete.
    private func networkFetch(_ task: Task?, completion: TaskCompletion? = nil) {
        guard let task = task else {
            completion?(nil, nil)
            return
        }
        
        // make sure task was not cancelled
        guard !task.isCancelled else {
            completion?(task.url, nil)
            return
        }
        
        // if image is already cached, notify all and return
        if let cachedPhoto = photo(for: task.url) {
            completion?(task.url, cachedPhoto)
            return
        }
        
        // setup network data task
        let configuration = URLSessionConfiguration.ephemeral //.default
        configuration.httpMaximumConnectionsPerHost = PhotoController.maxConcurrentDownloads
        let session = URLSession(configuration: configuration)
        let dataTask = session.dataTask(with: task.url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let data = data else {
                completion?(task.url, nil)
                return
            }
            completion?(task.url, UIImage(data: data))
        })
        task.dataTask = dataTask
        
        // fetch!
        dataTask.resume()
    }
    
    /// Maximum concurrent downloads.
    private static let maxConcurrentDownloads: Int = 9
    
}
