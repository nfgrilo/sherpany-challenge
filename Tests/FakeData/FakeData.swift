//
//  FakeData.swift
//  Tests
//
//  Created by Nuno Grilo on 29/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit
import CoreData
@testable import Sherpany_Posts

class FakeData {
    
    lazy var bundle: Bundle = {
        return Bundle(for: type(of: self))
    }()
    
    
    // MARK: - JSON Data
    
    lazy var allPostsData: Data = {
        let fileURL = bundle.url(forResource: "AllPosts", withExtension: "json")!
        return try! Data(contentsOf: fileURL)
    }()
    
    lazy var allUsersData: Data = {
        let fileURL = bundle.url(forResource: "AllUsers", withExtension: "json")!
        return try! Data(contentsOf: fileURL)
    }()
    
    lazy var allAlbumsData: Data = {
        let fileURL = bundle.url(forResource: "AllAlbums", withExtension: "json")!
        return try! Data(contentsOf: fileURL)
    }()
    
    lazy var allPhotosData: Data = {
        let fileURL = bundle.url(forResource: "AllPhotos", withExtension: "json")!
        return try! Data(contentsOf: fileURL)
    }()
    
    lazy var onePostData: Data = {
        let fileURL = bundle.url(forResource: "OnePost", withExtension: "json")!
        return try! Data(contentsOf: fileURL)
    }()
    
    lazy var oneUserData: Data = {
        let fileURL = bundle.url(forResource: "OneUser", withExtension: "json")!
        return try! Data(contentsOf: fileURL)
    }()
    
    lazy var oneAlbumData: Data = {
        let fileURL = bundle.url(forResource: "OneAlbum", withExtension: "json")!
        return try! Data(contentsOf: fileURL)
    }()
    
    lazy var onePhotoData: Data = {
        let fileURL = bundle.url(forResource: "OnePhoto", withExtension: "json")!
        return try! Data(contentsOf: fileURL)
    }()
    
    lazy var samplePhoto: UIImage = {
        return UIImage(contentsOfFile: samplePhotoURL.path)!
    }()
    
    lazy var samplePhotoURL: URL = {
        let fileURL = bundle.url(forResource: "SamplePhoto", withExtension: "png")!
        return fileURL
    }()
    
    
    // MARK: - Core Data data
    
    /// Create mock data.
    func createFakeData(in context: NSManagedObjectContext) {
        context.performAndWait {
            // user 1
            let user1 = ManagedUser(context: context)
            user1.id = 1
            user1.name = "User 1"
            user1.username = "user1"
            user1.email = "user1@email.com"
            
            // user 2
            let user2 = ManagedUser(context: context)
            user2.id = 2
            user2.name = "User 2"
            user2.username = "user2"
            user2.email = "user2@email.com"
            
            // user 999999
            let user999999 = ManagedUser(context: context)
            user999999.id = 999999
            user999999.name = "User 999999"
            user999999.username = "user999999"
            user999999.email = "user999999@email.com"
            
            // post 1
            let post1 = ManagedPost(context: context)
            post1.id = 1
            post1.title = "Post 1"
            post1.user = user1
            user1.addToPosts(post1)
            
            // post 2
            let post2 = ManagedPost(context: context)
            post2.id = 2
            post2.title = "Post 2"
            post2.user = user1
            user1.addToPosts(post2)
            
            // album 1
            let album1 = ManagedAlbum(context: context)
            album1.id = 1
            album1.title = "Album 1"
            album1.user = user1
            
            // photo 1
            let photo1 = ManagedPhoto(context: context)
            photo1.id = 1
            photo1.title = "Photo 1"
            photo1.url = URL(string: "http://someplace.com/photo/1")
            photo1.thumbnailUrl = URL(string: "http://someplace.com/thumb/1")
            photo1.album = album1
            album1.addToPhotos(photo1)
            
            // save
            do {
                try context.save()
            }
            catch {
                print("Error creating fake data: \(error)")
            }
        }
    }
    
    /// Clean up fake data.
    func removeFakeData(in context: NSManagedObjectContext) {
        context.performAndWait {
            let userRequest: NSFetchRequest<ManagedUser> = ManagedUser.fetchRequest()
            for obj in (try! context.fetch(userRequest)) {
                context.delete(obj)
            }
            try! context.save()
        }
    }
    
}
