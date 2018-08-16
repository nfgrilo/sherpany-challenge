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
    
    /// REST API controller.
    private var apiController: APIController?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // window
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        // shared controllers
        let apiController = APIController()
        self.apiController = apiController
        let modelController = ModelController(apiController: apiController)
        self.modelController = modelController
        
        // main coordinator
        let coordinator = MainCoordinator(window: window, modelController: modelController)
        self.coordinator = coordinator
        
        // let main coordinator take control
        coordinator.start()
        
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Requirement #3: ✅ (fetch data every time the app becomes active)
        modelController?.refreshDataOnline()
    }

}

