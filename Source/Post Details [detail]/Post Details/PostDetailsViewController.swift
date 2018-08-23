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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        /// re-layout when device changes orientation
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.invalidateLayout()
        }
    }
    
}

