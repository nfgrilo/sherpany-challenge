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
    
    /// REST API controller.
    private var apiController: APIController
    
    init(apiController: APIController) {
        self.apiController = apiController
    }
    
    
    // MARK: - Model access
    
    /// Retrieve all posts as `[Post]` - the immutable & thread-safe version of `ManagedPost`.
    ///
    /// - Parameter completion: An array of `Post` objects.
    func allPosts(completion: @escaping ([Post]) -> Void) {
        persistentContainer.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<ManagedPost> = ManagedPost.fetchRequest()
            fetchRequest.relationshipKeyPathsForPrefetching = ["user"]
            
            var posts: [Post] = []
            do {
                let managedPosts = try context.fetch(fetchRequest) as [ManagedPost]
                for managedPost in managedPosts {
                    let post = Post(managedPost: managedPost, fetchUserAlbums: false)
                    print("Processing \(post)")
                    posts.append(post)
                }
            } catch {
                print("Failed to retrieve posts with error: \(error)")
            }
            
            completion(posts)
        }
    }
    
    
    // MARK: - Rest API interaction
    
    /// Refreshes all data.
    ///
    /// This will fetch all the data from the REST API and merge it with existing
    /// persisted data on Core Data.
    func refreshDataOnline() {
        // 1. fetch all data at once (Requirement #3)
        apiController.fetchAllData { [weak self] result in
            // this closure is executed on a background thread (background QOS)
            
            var onlineData: AggregateResponse?
            
            // process fetch result
            switch result {
            case .success(let response):
                onlineData = response.first
            case .failure(let error):
                print("Error fetching online data: \(error)")
                return
            }
            guard let fetchedData = onlineData else { return }
            
            // 2. merge fetched data with persisted data
            self?.mergeData(from: fetchedData)
        }
    }
    
    /// Merges fetched data with persisted data.
    ///
    /// Requirement #5: ✅ (merge fetched data with persisted data)
    ///
    /// - Parameter fetchedData: An `AggregateResponse` object with all fresh fetched data.
    private func mergeData(from fetchedData: AggregateResponse) {
        // Merging will be performed by:
        //  - removing any persisted item that is not on fetched data (never happens on this app)
        //  - making use of "upsert", that is, checking if entity exists by
        //    its `id`, creating a new one if needed:
        //      * added `id` as Entity Constraint to all entities
        //      * adjusted managed object context merge policy
        persistentContainer.performBackgroundTask({ [weak self] (context) in
            
            // merge operations should occur on a property basis (`id`)
            // and the in memory version “wins” over the persisted one.
            // all entities have been modeled with an `id` constraint.
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
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
                    print("Successfuly saved to Core Data")
                }
            } catch {
                print("Failed to save to Core Data: \(error)")
                return
            }
        })
    }
    
    
    // MARK: - Deletions
    
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
                print("Deleting \(object)")
                context.delete(object)
            }
        } catch {
            print("Failed to delete entries with error: \(error)")
        }
    }
    
 
    // MARK: - Core Data stack
    
    /// The Core Data container that encapsulates the entire Core Data stack.
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Posts")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Failed to load Core Data stack: \(error), \(error.userInfo)")
            }
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        })
        return container
    }()
    
}
