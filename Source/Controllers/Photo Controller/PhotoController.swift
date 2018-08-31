//
//  PhotoController.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 21/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

// Requirement #11: ✅ (pre-fetching & caching)

/// Fetch photos from the network.
class PhotoController {
    
    /// Alias for task completion closure.
    typealias TaskCompletion = (URL?, UIImage?) -> Void
    
    /// A photo network fetch object.
    class Task: Hashable {
        let url: URL
        var completions: [TaskCompletion] = []
        var workItem: DispatchWorkItem?
        var dataTask: URLSessionDataTask?
        var priority: Priority = .normal
        private(set) var isCancelled: Bool = false
        
        init(url: URL, completions: [TaskCompletion]) {
            self.url = url
            self.completions = completions
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
        
        enum Priority: Int {
            case veryLow = 0
            case low
            case normal
            case high
        }
    }
    
    /// Queue of waiting tasks.
    ///
    /// Reads are made synchronously on the concurrent `tasksQueue` queue.
    /// Writes are made without concurrency (asynchronously with barrier).
    private var tasks: [Task] = []
    
    /// Tasks being executed.
    ///
    /// Keep a strong ref otherwise task would be derreferenced before finishing.
    /// Reads are made synchronously on the concurrent `tasksQueue` queue.
    /// Writes are made without concurrency (asynchronously with barrier).
    private var executingTasks: [Task] = []
    
    /// URL session used to make requests.
    private var session: URLSession
    
    
    /// Initialize the controller.
    ///
    /// - Parameter session: An optional pre-configured URL session (usefull for testing).
    init(session: URLSession? = nil) {
        // URL session to use
        if let session = session {
            self.session = session
        }
        else {
            //  > PS: `URLSessionConfiguration.default` should be used instead to take
            //  > advantage of disk caching of photos, etc. However, for the code challenge
            //  > purpose, it is intentionally using `.ephemeral` (no disk cache - memory only).
            let configuration = URLSessionConfiguration.ephemeral
            configuration.httpMaximumConnectionsPerHost = PhotoController.maxConcurrentDownloads
            let session = URLSession(configuration: configuration)
            self.session = session
        }
        
        // limit number of cached photos
        cache.countLimit = 500
        
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
    ///   - priority: Priority for these URLs.
    ///   - completion: The closure to be called when complete.
    func fetchPhotos(from urls: [URL], priority: Task.Priority = .normal, completion: TaskCompletion? = nil) {
        let priorities = urls.map { _ in priority }
        fetchPhotos(from: urls, priorities: priorities, completion: completion)
    }
    
    /// Fetch and cache photos from the network.
    ///
    /// - Parameters:
    ///   - urls: The photo URLs.
    ///   - priorities: Priorities for each of these URLs.
    ///   - completion: The closure to be called when complete.
    func fetchPhotos(from urls: [URL], priorities: [Task.Priority]? = nil, completion: TaskCompletion? = nil) {
        var newTasks: [Task] = []
        for i in 0..<urls.count {
            let url = urls[i]
            
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
            //  -> update priority
            if let priorities = priorities {
                let priorityIndex = max(0, min(i, priorities.count - 1))
                if priorityIndex < priorities.count {
                    task.priority = priorities[priorityIndex]
                }
            }
            //  -> define task work item (fetch image & notify "observers")
            if task.workItem == nil {
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
    
    /// Gets an existing queued task for the given url, creating one if appropriate,
    /// and appending a completion closure to that task (bound to `url`).
    ///
    /// - Parameters:
    ///   - url: The task url.
    ///   - createIfInexistent: Create a new task if not queued.
    ///   - taskCompletion: A completion closure to be added to the list of this url task.
    /// - Returns: A task associated with the given url.
    private func task(for url: URL,
                      createIfInexistent: Bool = false,
                      addCompletion taskCompletion: TaskCompletion? = nil) -> Task? {
        var task: Task?
        
        // `tasks` reads are made synchronously on a concurrent queue
        tasksQueue.sync { [weak self] in
            
            // search for existing task
            for existingTask in self?.tasks ?? [] {
                if url == existingTask.url {
                    task = existingTask
                    break
                }
            }
            
            // set task completions
            var completions: [TaskCompletion] = task?.completions ?? []
            if let taskCompletion = taskCompletion {
                completions.append(taskCompletion)
                task?.completions = completions
            }
            
            // create new task (?)
            if task == nil && createIfInexistent {
                task = Task(url: url, completions: completions)
            }
            
        }
        
        return task
    }
    
    /// Enqueue tasks.
    ///
    /// - Parameter tasks: The tasks to queue.
    private func enqueueTasks(_ tasks: [Task]) {
        let dispatchGroup = DispatchGroup()
        
        // `tasks` writes are made without concurrency (async with barrier)
        dispatchGroup.enter()
        tasksQueue.async(flags: .barrier) { [weak self] in
            // queue tasks
            for task in tasks {
                if let existingIndex = self?.tasks.index(of: task) {
                    // increase priority by removing and (re)appending
                    self?.tasks.remove(at: existingIndex)
                }
            }
            self?.tasks.append(contentsOf: tasks)
            
            dispatchGroup.leave()
        }
        
        // execute next task when complete
        dispatchGroup.notify(queue: .global(qos: .background)) { [weak self] in
            let executingTaskCount = self?.executingTasks.count ?? 0
            if executingTaskCount < PhotoController.maxConcurrentDownloads {
                self?.executeNextTask()
            }
        }
    }
    
    /// Dequeues and executes next task.
    private func executeNextTask() {
        dequeueTask { [weak self] task in
            guard let task = task else { return }
            
            // perform task on network queue
            self?.networkQueue.async {
                task.workItem?.perform()
            }
        }
    }
    
    /// Dequeue most recently queued task.
    ///
    /// - Parameter completion: The dequeued task.
    private func dequeueTask(completion: @escaping (Task?) -> ()) {
        // `tasks` writes are made without concurrency (async with barrier)
        tasksQueue.async(flags: .barrier) { [weak self] in
            guard let tasks = self?.tasks else {
                completion(nil)
                return
            }
            
            // sort by priority
            let sortedTasks = tasks.sorted { $0.priority.rawValue < $1.priority.rawValue }

            // get last (higher priority), non-cancelled task
            while !sortedTasks.isEmpty {
                if let task = sortedTasks.last, !task.isCancelled {
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
    ///
    /// - Parameter urls: The tasks urls.
    private func lowerTaskPriority(for urls: [URL]) {
        // `tasks` writes are made without concurrency (async with barrier)
        tasksQueue.async(flags: .barrier) { [weak self] in
            guard let tasks = self?.tasks else { return }
            
            for url in urls {
                // get task
                guard let task = (tasks.first { $0.url == url }) else { continue }
                
                // lower task priority
                if task.priority.rawValue > Task.Priority.veryLow.rawValue {
                    task.priority = Task.Priority(rawValue: task.priority.rawValue - 1) ?? .veryLow
                }
            }
        }
    }
    
    /// Cancel all tasks.
    private func cancelAllTasks() {
        // `tasks` writes are made without concurrency (async with barrier)
        tasksQueue.async(flags: .barrier) { [weak self] in
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
        // `tasks` writes are made without concurrency (async with barrier)
        tasksQueue.async(flags: .barrier) { [weak self] in
            if let existingIndex = self?.tasks.index(of: task) {
                self?.tasks.remove(at: existingIndex)
            }
            if let existingIndex = self?.executingTasks.index(of: task) {
                self?.executingTasks.remove(at: existingIndex)
            }
        }
        
        // execute next task
        executeNextTask()
    }
    
    /// Concurrent queue for queueing photo task requests.
    ///
    /// Reads should be made synchronously on the concurrent queue.
    /// Writes should made without concurrency (asynchronously with barrier).
    private let tasksQueue = DispatchQueue(label: "PhotoController Tasks Access", qos: .background, attributes: .concurrent)
    
    /// Concurrent queue for network requests.
    internal var networkQueue = DispatchQueue(label: "PhotoController Network Access", qos: .background, attributes: .concurrent)
    
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
    private static let maxConcurrentDownloads: Int = 10
    
}
