//
//  PostsViewController.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostsViewController: UIViewController, Storyboarded {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup views
        setupTableView()
        setupFeedbackView()
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
    
    
    // MARK: - Feedback view
    // Requirement #12: ✅ (UI feedback)
    
    /// Configure feedback view.
    private func setupFeedbackView() {
        guard let feedbackViewController = PostUIFeedbackViewController.instantiate() else { return }
        self.feedbackViewController = feedbackViewController
        feedbackViewController.attachTo(self)
    }
    
    /// The (hideable) loading view.
    private var feedbackViewController: PostUIFeedbackViewController?
    
    /// Show/hide the progress view.
    ///
    /// - Parameter show: Whether to show or hide it.
    func showProgressView(_ show: Bool) {
        feedbackViewController?.showProgressView(show)
    }
    
    /// Show/hide the search feedback view.
    ///
    /// - Parameter show: Whether to show or hide it.
    func setSearchFeedbackView(with text: String?) {
        feedbackViewController?.setSearchFeedbackView(with: text)
    }
    
}
