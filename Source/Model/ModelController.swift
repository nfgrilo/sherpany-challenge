//
//  ModelController.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation
import CoreData

// Requirement #4: ✅
// Requirement #5: ✅

class ModelController {
    
    /// REST API controller.
    private var apiController: APIController
    
    init(apiController: APIController) {
        self.apiController = apiController
    }
    
    
    // MARK: - Rest API interaction
    
    func refreshDataOnline() {
        
    }
    
 
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Posts")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Failed to load Core Data stack: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
        }
    }
    
}
