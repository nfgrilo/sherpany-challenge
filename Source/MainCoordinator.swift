//
//  MainCoordinator.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 13/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    /// Child coordinators.
    var childCoordinators: [Coordinator] = []
    
    /// The app window.
    private let window: UIWindow
    
    /// Model controller.
    private let modelController: ModelController
    
    /// The root view controller currently being used to present view controllers.
    private var splitViewController: UISplitViewController?
    
    
    /// Creates a new main coordinator.
    ///
    /// - Parameters:
    ///   - window: The app window.
    ///   - modelController: The model controller
    init(window: UIWindow, modelController: ModelController) {
        self.window = window
        self.modelController = modelController
    }
    
    /// Take control!
    func start() {
        // childs: coordinators + VCs
        //  -> master
        let masterNavigationController = UINavigationController()
        let masterCoordinator = PostsCoordinator(navigationController: masterNavigationController, modelController: modelController)
        childCoordinators.append(masterCoordinator)
        masterCoordinator.start()
        //  -> detail
        let detailNavigationController = UINavigationController()
        let detailsCoordinator = PostDetailsCoordinator(navigationController: detailNavigationController, modelController: modelController)
        childCoordinators.append(detailsCoordinator)
        detailsCoordinator.start()
        masterCoordinator.postSelectedDelegate = detailsCoordinator
        
        // root: split view controller -> Requirement #6: ✅
        let splitViewController = UISplitViewController()
        self.splitViewController = splitViewController
        splitViewController.viewControllers = [masterNavigationController, detailNavigationController]
        splitViewController.preferredDisplayMode = .allVisible
        splitViewController.minimumPrimaryColumnWidth = 300
        splitViewController.maximumPrimaryColumnWidth = splitViewController.minimumPrimaryColumnWidth
        
        // show
        window.rootViewController = splitViewController
        window.makeKeyAndVisible()
    }
    
}
