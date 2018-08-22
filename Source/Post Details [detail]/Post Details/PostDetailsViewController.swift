//
//  PostDetailsViewController.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 13/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostDetailsViewController: UICollectionViewController, Storyboarded {
    
    /// Weak reference to parent coordinator.
    weak var coordinator: PostDetailsCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let vc = PostTitleBodyViewController.instantiate(), let subView = vc.view {
//            subView.translatesAutoresizingMaskIntoConstraints = false
//            subView.frame.origin = .zero
//            collectionView?.addSubview(subView)
//            addChildViewController(vc)
//            vc.didMove(toParentViewController: self)
//        }
//        
//        collectionView?.contentInset.top = 200
    }
    
}

