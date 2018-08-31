//
//  AppDelegate.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 13/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit
import CoreData

// Requirement #2: ✅ (coded in Swift)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    /// The app's window.
    var window: UIWindow?
    
    /// Main coordinator.
    private var coordinator: MainCoordinator?
    
    /// Model controller.
    private var modelController: ModelController?
    
    /// Photo controller.
    private var photoController: PhotoController?
    
    /// REST API controller.
    private var apiController: APIController?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        guard NSClassFromString("XCTestCase") == nil else {
            // if running tests, return
            return false
        }
        
        // window
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        // shared controllers
        let apiController = APIController()
        self.apiController = apiController
        let modelController = ModelController(container: persistentContainer, apiController: apiController)
        self.modelController = modelController
        let photoController = PhotoController()
        self.photoController = photoController
        
        // main coordinator
        let coordinator = MainCoordinator(window: window, modelController: modelController, photoController: photoController)
        self.coordinator = coordinator
        
        // let main coordinator take control
        coordinator.start()
        
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Requirement #3: ✅ (fetch data every time the app becomes active)
        modelController?.refreshDataOnline()
    }

    
    // MARK: - Core Data stack
    
    /// The Core Data container that encapsulates the entire Core Data stack.
    lazy var persistentContainer: CoreDataContainer = {
        let container = CoreDataContainer(name: "Posts")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Failed to load Core Data stack: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
}


