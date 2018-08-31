//
//  MainCoordinator.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 13/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    
    /// The app window.
    private let window: UIWindow
    
    /// Model controller.
    private let modelController: ModelController
    
    /// Photo controller.
    private let photoController: PhotoController
    
    /// The root view controller currently being used to present view controllers.
    private var splitViewController: UISplitViewController?
    
    
    // MARK: - Application Coordinator
    
    /// Creates a new main coordinator.
    ///
    /// - Parameters:
    ///   - window: The app window.
    ///   - modelController: The model controller
    init(window: UIWindow, modelController: ModelController, photoController: PhotoController) {
        self.window = window
        self.modelController = modelController
        self.photoController = photoController
    }
    
    /// Take control!
    override func start() {
        // childs: coordinators + VCs
        //  -> master
        let masterNavigationController = UINavigationController()
        let masterCoordinator = PostsCoordinator(navigationController: masterNavigationController, modelController: modelController)
        addChild(masterCoordinator)
        masterCoordinator.start()
        //  -> detail
        let detailNavigationController = UINavigationController()
        let detailsCoordinator = PostDetailsCoordinator(navigationController: detailNavigationController, modelController: modelController, photoController: photoController)
        addChild(detailsCoordinator)
        detailsCoordinator.start()
        masterCoordinator.postSelectedDelegate = detailsCoordinator
        
        // root: split view controller -> Requirement #6: ✅
        let splitViewController = UISplitViewController()
        self.splitViewController = splitViewController
        splitViewController.viewControllers = [masterNavigationController, detailNavigationController]
        splitViewController.preferredDisplayMode = .allVisible
        splitViewController.minimumPrimaryColumnWidth = 300
        splitViewController.maximumPrimaryColumnWidth = splitViewController.minimumPrimaryColumnWidth
        
        // setup navigation bar
        //  -> set status bar white (+ `UIViewControllerBasedStatusBarAppearance=NO` on Info.plist)
        UIApplication.shared.statusBarStyle = .lightContent
        //  -> hide text on back buttons (only showing "<")
        UIBarButtonItem.appearance().setTitleTextAttributes([ .foregroundColor: UIColor.clear ], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([ .foregroundColor : UIColor.clear ], for: .highlighted)
        
        // show
        window.rootViewController = splitViewController
        window.makeKeyAndVisible()
    }
    
    
    // MARK: - Network Activity Indication
    
    /// Number of current active network requests.
    private var activeRequestsCount: Int = 0 {
        didSet {
            showNetworkActivityIndicator(activeRequestsCount > 0)
        }
    }
    
    /// Shows the indicator of network activity on status bar On or Off.
    ///
    /// - Parameter show: Whether to show or hide indicator.
    func showNetworkActivityIndicator(_ show: Bool) {
        DispatchQueue.main.async {
            if UIApplication.shared.isNetworkActivityIndicatorVisible != show {
                UIApplication.shared.isNetworkActivityIndicatorVisible = show
            }
        }
    }
    
}


extension MainCoordinator: APIControllerDelegate, PhotoControllerDelegate {
    
    // MARK: APIControllerDelegate
    
    func willFetchResource(with: URL) {
        activeRequestsCount += 1
    }
    
    func didFetchResource(with: URL) {
        activeRequestsCount -= 1
    }
    
    // MARK: PhotoControllerDelegate
    
    func willFetchPhoto(with: URL) {
        activeRequestsCount += 1
    }
    
    func didFetchPhoto(with: URL) {
        activeRequestsCount -= 1
    }
    
    
}
