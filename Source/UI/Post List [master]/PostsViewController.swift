//
//  PostsViewController.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostsViewController: UIViewController, Storyboarded {
    
    /// Weak reference to parent coordinator.
    weak var coordinator: PostsCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupLoadingView()
    }
    
    
    // MARK: - Table view
    
    /// The table view.
    @IBOutlet weak var tableView: UITableView!
    
    /// Configure table view.
    private func setupTableView() {
        // dynamic row heights based on auto layout
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // height estimate helps improving performance on row height calculation
        tableView.estimatedRowHeight = 84
    }
    
    
    // MARK: - Loading view
    
    /// The (hideable) loading view.
    @IBOutlet weak var loadingView: UIVisualEffectView!
    
    /// Configure table view.
    private func setupLoadingView() {
        // add a top line
        loadingView.clipsToBounds = true
        let topBorder = CALayer()
        topBorder.borderColor = (UIColor(named: "Separator") ?? UIColor.lightGray).cgColor
        topBorder.borderWidth = 0.5
        topBorder.frame = CGRect(x: 0, y: topBorder.borderWidth, width: loadingView.frame.width, height: topBorder.borderWidth)
        loadingView.layer.addSublayer(topBorder)
    }
    
    /// The loading view bottom constraint.
    @IBOutlet weak var loadingViewBottomConstraint: NSLayoutConstraint!
    
    /// Show/hide the loading view.
    ///
    /// Requirement #12: ✅ (UI feedback)
    ///
    /// - Parameter show: Whether to show or hide it.
    func showLoadingView(_ show: Bool) {
        // view height
        loadingView.layoutIfNeeded()
        let height = loadingView.frame.height
        loadingViewBottomConstraint.constant = show ? 0 : -height
        view.setNeedsUpdateConstraints()
        
        // animate bottom anchor
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
}
