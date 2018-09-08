//
//  PostsViewController.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

protocol PostsViewControllerProtocol: NSObjectProtocol, Storyboarded, FeedbackVisible {
    
    var tableView: UITableView! { get set }
    
}

class PostsViewController: UIViewController, PostsViewControllerProtocol, Storyboarded {
    
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
    
}


// MARK: - FeedbackVisible protocol
extension PostsViewController: FeedbackVisible {
    
    var isProgressViewVisible: Bool {
        get {
            return feedbackViewController?.isProgressViewVisible ?? false
        }
        set {
            feedbackViewController?.isProgressViewVisible = newValue
        }
    }
    
    var searchFeedbackText: String? {
        get {
            return feedbackViewController?.searchFeedbackText
        }
        set {
            feedbackViewController?.searchFeedbackText = newValue
        }
    }
    
}
