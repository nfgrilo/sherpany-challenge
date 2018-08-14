//
//  MainCoordinator.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 13/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    /// Master child coordinator.
    var masterCoordinator: PostsCoordinator?
    
    /// Detail child coordinator.
    var detailCoordinator: PostDetailsCoordinator?
    
    /// The root view controller currently being used to present view controllers.
    let splitViewController: UISplitViewController
    
    /// The app window.
    let window: UIWindow
    
    /// Creates a new main coordinator.
    ///
    /// - Parameter window: The app window.
    init(window: UIWindow) {
        self.window = window
        
        // childs: coordinators + VCs
        //  -> master
        let masterNavigationController = UINavigationController()
        masterCoordinator = PostsCoordinator(navigationController: masterNavigationController)
        masterCoordinator?.start()
        //  -> detail
        let detailNavigationController = UINavigationController()
        detailCoordinator = PostDetailsCoordinator(navigationController: detailNavigationController)
        detailCoordinator?.start()
        masterCoordinator?.postSelectedDelegate = detailCoordinator
        
        // root: split view controller -> // Requirement #6: ✅
        splitViewController = UISplitViewController()
        splitViewController.viewControllers = [masterNavigationController, detailNavigationController]
        splitViewController.preferredDisplayMode = .allVisible
        splitViewController.minimumPrimaryColumnWidth = 300
        splitViewController.maximumPrimaryColumnWidth = splitViewController.minimumPrimaryColumnWidth
    }
    
    /// Take control!
    func start() {
        window.rootViewController = splitViewController
        window.makeKeyAndVisible()
    }
    
}
