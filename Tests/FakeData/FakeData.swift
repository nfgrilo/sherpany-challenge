//
//  FakeData.swift
//  Tests
//
//  Created by Nuno Grilo on 29/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class FakeData {
    
    lazy var bundle: Bundle = {
        return Bundle(for: type(of: self))
    }()
    
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
    
}
