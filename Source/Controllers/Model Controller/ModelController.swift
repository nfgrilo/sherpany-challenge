//
//  ModelController.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation
import CoreData

// Requirement #4: ✅ (persist in Core Data with relationships)

class ModelController {
    
    /// Persistent store coordinator.
    private var container: CoreDataContainer
    
    /// REST API controller.
    private var apiController: APIController
    
    /// Delegates (weak reference to delegates).
    ///
    /// This is handled on `ModelController+Delegate`.
    fileprivate var delegates = NSPointerArray.weakObjects()
    
    
    /// Initialize the model controller.
    ///
    /// - Parameters:
    ///   - container: The shared instance of Core Data container.
    ///   - apiController: The shared instance of API controller for data fetching.
    init(container: CoreDataContainer, apiController: APIController) {
        self.container = container
        self.apiController = apiController
    }
    
    
    // MARK: - Posts
    
    /// Retrieve all posts as `[Post]` - the immutable & thread-safe version of `ManagedPost`.
    ///
    /// - Parameter completion: An array of `Post` objects.
    func allPosts(completion: @escaping ([Post]) -> Void) {
        // reads can be done on readonly main context
        let context = container.mainManagedObjectContext
        context.perform {
            // setup fetch request
            let fetchRequest: NSFetchRequest<ManagedPost> = ManagedPost.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            //  -> pre-fetching avoiding multiple fault fires
            fetchRequest.relationshipKeyPathsForPrefetching = ["user"]
            
            var posts: [Post] = []
            do {
                let managedPosts = try context.fetch(fetchRequest) as [ManagedPost]
                for managedPost in managedPosts {
                    let post = Post(managedPost: managedPost)
                    posts.append(post)
                }
            } catch {
                print("Failed to retrieve posts with error: \(error)")
            }
            
            completion(posts)
        }
    }
    
    /// Gets the post with the specified id
    ///
    /// - Parameters:
    ///   - id: The post id.
    ///   - completion: Completion closure called when complete.
    func post(with id: Int64, completion: @escaping (Post?) -> Void) {
        // reads can be done on readonly main context
        let context = container.mainManagedObjectContext
        context.perform {
            // setup fetch request
            let fetchRequest: NSFetchRequest<ManagedPost> = ManagedPost.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %i", id)
            //  -> pre-fetching avoiding multiple fault fires
            fetchRequest.relationshipKeyPathsForPrefetching = ["user.albums.photos"]
            fetchRequest.fetchLimit = 1
            
            // get post
            var post: Post?
            do {
                if let managedPost = try context.fetch(fetchRequest).first {
                    post = Post(managedPost: managedPost, fetchUserAlbums: true)
                }
            } catch {
                print("Failed to get post with error: \(error)")
            }
            
            // call completion
            completion(post)
        }
    }
    
    /// Remove the post with the specified id.
    ///
    /// - Parameters:
    ///   - id: The post id.
    ///   - completion: Completion closure called when complete.
    func removePost(_ id: Int64, completion: (() -> Void)? = nil) {
        guard !isRefreshingData else {
            // refreshing/merging data? -> remove the object later
            let context = container.mainManagedObjectContext
            context.perform { [weak self] in
                self?.queuePostForRemoval(id: id, in: context)
            }
            
            // call completion & return
            completion?()
            return
        }
        
        // writes are done on background on a private queue
        let context = container.backgroundManagedObjectContext
        context.perform { [weak self] in
            // setup fetch request
            let fetchRequest: NSFetchRequest<ManagedPost> = ManagedPost.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %i", id)
            fetchRequest.fetchLimit = 1
            
            // remove post
            do {
                if let object = try context.fetch(fetchRequest).first {
                    context.delete(object)
                }
                try context.save()
            } catch {
                print("Failed to delete post with error: \(error)")
            }
            
            // call completion
            completion?()
            
            // notify delegates
            self?.notifyDelegates() { delegate in
                delegate.postWasRemoved(postId: id)
            }
        }
    }
    
    
    // MARK: - Users
    
    /// Gets the user with the specified id
    ///
    /// - Parameters:
    ///   - id: The user id.
    ///   - completion: Completion closure called when complete.
    func user(with id: Int64, completion: @escaping (User?) -> Void) {
        // reads can be done on readonly main context
        let context = container.mainManagedObjectContext
        context.perform {
            // setup fetch request
            let fetchRequest: NSFetchRequest<ManagedUser> = ManagedUser.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %i", id)
            fetchRequest.fetchLimit = 1
            
            // get post
            var user: User?
            do {
                if let managedUser = try context.fetch(fetchRequest).first {
                    user = User(managedUser: managedUser)
                }
            } catch {
                print("Failed to get user with error: \(error)")
            }
            
            // call completion
            completion(user)
        }
    }
    
    
    // MARK: - Albums
    
    /// Gets the album with the specified id
    ///
    /// - Parameters:
    ///   - id: The album id.
    ///   - completion: Completion closure called when complete.
    func album(with id: Int64, completion: @escaping (Album?) -> Void) {
        // reads can be done on readonly main context
        let context = container.mainManagedObjectContext
        context.perform {
            // setup fetch request
            let fetchRequest: NSFetchRequest<ManagedAlbum> = ManagedAlbum.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %i", id)
            //  -> pre-fetching avoiding multiple fault fires
            fetchRequest.relationshipKeyPathsForPrefetching = ["photos"]
            fetchRequest.fetchLimit = 1
            
            // get post
            var album: Album?
            do {
                if let managedAlbum = try context.fetch(fetchRequest).first {
                    album = Album(managedAlbum: managedAlbum)
                }
            } catch {
                print("Failed to get album with error: \(error)")
            }
            
            // call completion
            completion(album)
        }
    }
    
    
    // MARK: - Photos
    
    /// Gets the photo with the specified id
    ///
    /// - Parameters:
    ///   - id: The photo id.
    ///   - completion: Completion closure called when complete.
    func photo(with id: Int64, completion: @escaping (Photo?) -> Void) {
        // reads can be done on readonly main context
        let context = container.mainManagedObjectContext
        context.perform {
            // setup fetch request
            let fetchRequest: NSFetchRequest<ManagedPhoto> = ManagedPhoto.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %i", id)
            fetchRequest.fetchLimit = 1
            
            // get post
            var photo: Photo?
            do {
                if let managedPhoto = try context.fetch(fetchRequest).first {
                    photo = Photo(managedPhoto: managedPhoto)
                }
            } catch {
                print("Failed to delete photo with error: \(error)")
            }
            
            // call completion
            completion(photo)
        }
    }
    
    
    // MARK: - Refresh Data (REST API interaction)
    
    /// Are we fetching & merging data with persisted one?
    private var isRefreshingData: Bool = false
    
    /// Refreshes all data.
    ///
    /// This will fetch all the data from the REST API and merge it with existing
    /// persisted data on Core Data.
    ///
    /// - Parameter completion: Completion closure called when complete.
    func refreshDataOnline(completion: ((Bool) -> Void)? = nil) {
        guard !isRefreshingData else {
            return
        }
        isRefreshingData = true
        
        // 1. fetch all data at once (Requirement #3)
        notifyDelegates() { delegate in
            delegate.dataWillRefresh()
        }
        apiController.fetchAllData { [weak self] result in
            
            // final complete closure
            let finishClosure: (Bool) -> Void = { success in
                completion?(success)
                self?.notifyDelegates() { delegate in
                    delegate.dataDidRefresh(success: success)
                }
                self?.isRefreshingData = false
            }
            
            var onlineData: AggregateResponse?
            
            // process fetch result
            switch result {
            case .success(let response):
                onlineData = response.first
            case .failure(_):
                finishClosure(false)
                return
            }
            guard let fetchedData = onlineData else {
                finishClosure(false)
                return
            }
            
            // 2. merge fetched data with persisted data
            //    & call completion
            //    & notify delegates when done
            self?.mergeData(from: fetchedData) {
                finishClosure(true)
            }
        }
    }
    
    /// Merges fetched data with persisted data.
    ///
    /// Requirement #5: ✅ (merge fetched data with persisted data)
    ///
    /// - Parameters:
    ///   - fetchedData: An `AggregateResponse` object with all fresh fetched data.
    ///   - completion: Completion closure called when complete.
    private func mergeData(from fetchedData: AggregateResponse, completion: (() -> Void)? = nil) {
        // Merging will be performed by:
        //  - removing any persisted item that is not on fetched data (never happens on this app)
        //  - making use of "upsert", that is, checking if entity exists by
        //    its `id`, creating a new one if needed:
        //      * added `id` as Entity Constraint to all entities
        //      * adjusted managed object context merge policy
        
        let context = container.backgroundManagedObjectContext
        context.perform { [weak self] in
            // 2.1 remove "orphans"
            self?.removeOrphans(using: fetchedData, in: context)
            
            // 2.2 update data
            // helper dictionaries for setting up the relationships
            // so this can be made in O(n) for time and space complexity
            var userIdToManagedUser: [Int: ManagedUser] = [:]
            var albumdIdToManagedAlbum: [Int: ManagedAlbum] = [:]
            
            // 2.2.1 User
            for fetchedUser in fetchedData.users {
                // create managed object
                let managedUser = ManagedUser(context: context)
                managedUser.id = Int64(fetchedUser.id)
                managedUser.name = fetchedUser.name
                managedUser.username = fetchedUser.username
                managedUser.email = fetchedUser.email
                
                // add to map
                userIdToManagedUser[fetchedUser.id] = managedUser
            }
            
            // 2.2.2 Post
            for fetchedPost in fetchedData.posts {
                // create managed object
                let managedPost = ManagedPost(context: context)
                managedPost.id = Int64(fetchedPost.id)
                managedPost.title = fetchedPost.title
                managedPost.body = fetchedPost.body
                
                // setup relationships
                if let managedUser = userIdToManagedUser[fetchedPost.userId] {
                    managedPost.user = managedUser
                    managedUser.addToPosts(managedPost)
                }
            }
            
            // 2.2.3 Album
            for fetchedAlbum in fetchedData.albums {
                // create managed object
                let managedAlbum = ManagedAlbum(context: context)
                managedAlbum.id = Int64(fetchedAlbum.id)
                managedAlbum.title = fetchedAlbum.title
                
                // setup relationships
                if let managedUser = userIdToManagedUser[fetchedAlbum.userId] {
                    managedAlbum.user = managedUser
                    managedUser.addToAlbums(managedAlbum)
                }
                
                // add to map
                albumdIdToManagedAlbum[fetchedAlbum.id] = managedAlbum
            }
            
            // 2.2.4 Photo
            for fetchedPhoto in fetchedData.photos {
                // create managed object
                let managedPhoto = ManagedPhoto(context: context)
                managedPhoto.id = Int64(fetchedPhoto.id)
                managedPhoto.title = fetchedPhoto.title
                managedPhoto.url = fetchedPhoto.url
                managedPhoto.thumbnailUrl = fetchedPhoto.thumbnailUrl
                
                // setup relationships
                if let managedAlbum = albumdIdToManagedAlbum[fetchedPhoto.albumId] {
                    managedPhoto.album = managedAlbum
                    managedAlbum.addToPhotos(managedPhoto)
                }
            }
            
            // 2.3 save managed object context
            do {
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                print("Failed to save to Core Data: \(error).")
            }
            
            // 2.4 perform any pending object removal *after* saving the context
            //     since the process takes long time due to merging taking place.
            //
            //     Doing it here will guarantee that the app will get the most
            //     up-to-date data when completion closure and/or delgate method
            //     is called.
            self?.removePendingRemovals(in: context)
            
            // finish
            completion?()
        }
    }
    
    /// Remove "orphan" objects from CoreData when compared to fetched data.
    ///
    /// - Parameters:
    ///   - fetchedData: The newly fetched data.
    ///   - context: The managed object context
    private func removeOrphans(using fetchedData: AggregateResponse, in context: NSManagedObjectContext) {
        // remove "orphan" posts
        let newPostIDs = fetchedData.posts.compactMap { return Int64($0.id) }
        removeObjects(from: "ManagedPost", notInIDList: newPostIDs, in: context)
        
        // remove "orphan" users
        //  -> because delete rule is set to cascade, albums & photos from these
        //      users will also be removed.
        let newUserIDs = fetchedData.users.compactMap { return Int64($0.id) }
        removeObjects(from: "ManagedUser", notInIDList: newUserIDs, in: context)
    }
    
    /// Remove objects identified by sepecified ids.
    ///
    /// This function does not use batch deletes since it doesn't play well with
    /// relationships.
    ///
    /// - Parameters:
    ///   - entityName: The Core Data entity name.
    ///   - ids: The object ids to be deleted.
    ///   - context: The managed object context.
    private func removeObjects(from entityName: String, notInIDList: [Int64], in context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "NOT (id IN %@)", notInIDList)
        
        do {
            let objects = try context.fetch(fetchRequest) as? [NSManagedObject]
            for object in objects ?? [] {
                context.delete(object)
            }
        } catch {
            print("Failed to delete entries with error: \(error)")
        }
    }
    
    
    // MARK: - Postponed object (posts) removals
    
    /// Concurrent queue for queueing objects for removal.
    ///
    /// If a data refresh is in place, object removals will be postponed for later.
    private let pendingRemovalsQueue = DispatchQueue(label: "ModelController Removal List Access", qos: .background, attributes: .concurrent)
    
    /// Objects pending removal.
    private var pendingRemovals: [NSManagedObjectID] = []
    
    /// Queue a post for removal later.
    ///
    /// - Parameters:
    ///   - id: The post ID.
    ///   - context: Perform the operation on the given context.
    private func queuePostForRemoval(id: Int64, in context: NSManagedObjectContext) {
        // setup fetch request
        let fetchRequest: NSFetchRequest<ManagedPost> = ManagedPost.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %i", id)
        fetchRequest.fetchLimit = 1
        
        // get post managed object id
        do {
            if let objectID = try context.fetch(fetchRequest).first?.objectID {
                pendingRemovalsQueue.async { [weak self] in
                    self?.pendingRemovals.append(objectID)
                }
            }
        } catch {
            print("Failed to get post managed object id with error: \(error)")
        }
    }
    
    /// Remove objects pending for removal.
    ///
    /// - Parameter context: Perform the operation on the given context.
    private func removePendingRemovals(in context: NSManagedObjectContext) {
        var objectsIDs: [NSManagedObjectID] = []
        pendingRemovalsQueue.sync(flags: .barrier) { [weak self] in
            objectsIDs = self?.pendingRemovals ?? []
            self?.pendingRemovals.removeAll()
        }
        if !objectsIDs.isEmpty {
            objectsIDs.compactMap { context.object(with: $0) }.forEach {
                context.delete($0)
            }
            do {
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                print("Failed to save to Core Data: \(error).")
            }
        }
    }
    
}


// MARK: - Delegate handling.

extension ModelController {
    
    /// Adds a new delegate.
    ///
    /// - Parameter delegate: The new delegate.
    func addDelegate(_ delegate: ModelControllerDelegate) {
        delegates.addObject(delegate)
    }
    
    /// Removes the specified delegate.
    ///
    /// - Parameter delegate: The delegate to be removed.
    func removeDelegate(_ delegate: ModelControllerDelegate) {
        delegates.removeObject(delegate)
    }
    
    /// Notify delegates by calling a closure for each delegate.
    ///
    /// - Parameter closure: The closure to be called for each delegate.
    func notifyDelegates(_ closure: (ModelControllerDelegate) -> Void) {
        registeredDelegates().forEach {
            closure($0)
        }
    }
    
    /// Gets existing delegates.
    ///
    /// - Returns: An array of delegates.
    func registeredDelegates() -> [ModelControllerDelegate] {
        var list: [ModelControllerDelegate] = []
        for i in 0..<delegates.count {
            if let delegate = delegates.object(at: i) as? ModelControllerDelegate {
                list.append(delegate)
            }
        }
        return list
    }
    
}
