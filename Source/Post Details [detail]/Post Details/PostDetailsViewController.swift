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
    
    /// Reloads collection view data & optionally restore scrolling offset.
    ///
    /// - Parameter restoreScrolling: Should restore scrolling offset?
    func reloadData(restoreScrolling: Bool = true) {
        guard let collectionView = self.collectionView else { return }
        
        // remember scrolling offset
        let previousScrollOffset = collectionView.contentOffset
        
        // reload post data
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        collectionView.reloadData()
        CATransaction.commit()
        
        // handle scroll offset
        if restoreScrolling {
            // restore previous scrolling offset
            collectionView.setContentOffset(previousScrollOffset, animated: false)
        }
        else {
            // scroll to top if post changed
            var offset = CGPoint(x: -collectionView.contentInset.left, y: -collectionView.contentInset.top)
            if #available(iOS 11.0, *) {
                offset = CGPoint(x: -collectionView.adjustedContentInset.left, y: -collectionView.adjustedContentInset.top)
            }
            collectionView.setContentOffset(offset, animated: false)
        }
    }
    
}

