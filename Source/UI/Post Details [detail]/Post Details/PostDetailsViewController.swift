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
    
    /// Reloads collection view data & optionally restore scrolling offset.
    ///
    /// - Parameter restoreScrolling: Should restore scrolling offset?
    func reloadData(restoreScrolling: Bool = true) {
        guard let collectionView = self.collectionView else { return }
        
        // remember scrolling offset
        let previousScrollOffset = collectionView.contentOffset
        
        // reload post data
        collectionView.reloadData()
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // refresh for Dynamic Type
        // Bonus #6: ✅ (Dynamic Type support)
        // All fonts are defined with Dynamic Type support; this refresh is the
        // only "manual" refresh needed.
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil, queue: nil) { [weak self] _ in
            self?.reloadData(restoreScrolling: true)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        /// re-layout when device changes orientation
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.invalidateLayout()
        }
    }
    
}

