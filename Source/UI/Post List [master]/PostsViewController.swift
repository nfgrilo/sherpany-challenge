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
        
        // setup views
        setupTableView()
        setupLoadingView()
        setupSearchFeedbackView()
        
        // register for keyboard show/hide notifications
        setupNotifications()
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
    // Requirement #12: ✅ (UI feedback)
    
    /// Configure loading view.
    private func setupLoadingView() {
        addTopBorder(to: loadingView)
    }
    
    /// The (hideable) loading view.
    @IBOutlet weak var loadingView: UIVisualEffectView!
    
    /// The loading view bottom constraint.
    @IBOutlet weak var loadingViewBottomConstraint: NSLayoutConstraint!
    
    /// Is loading view visible?
    private var isLoadingViewVisible: Bool = false
    
    /// The bottom offset.
    ///
    /// This value can be different from 0 (zero) if keyboard is shown.
    private var bottomOffset: CGFloat = 0 {
        didSet {
            refreshLoadingView()
        }
    }
    
    /// Show/hide the loading view.
    ///
    /// - Parameter show: Whether to show or hide it.
    func showLoadingView(_ show: Bool) {
        isLoadingViewVisible = show
        
        // view height
        loadingView.layoutIfNeeded()
        let height = loadingView.frame.height
        loadingViewBottomConstraint.constant = bottomOffset + (show ? 0 : (-height))
        view.setNeedsUpdateConstraints()
        
        // animate bottom anchor
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    /// Adjust loading view anchor constraint.
    func refreshLoadingView() {
        showLoadingView(isLoadingViewVisible)
    }
    
    
    // MARK: - Search feedback view
    // Bonus #3: ✅ (search live feedback)
    
    /// Configure loading view.
    private func setupSearchFeedbackView() {
        addTopBorder(to: searchFeedbackView)
        setSearchFeedbackView(with: nil)
    }
    
    /// The (hideable) search feedback view.
    @IBOutlet weak var searchFeedbackView: UIVisualEffectView!
    
    /// The search feedback text.
    @IBOutlet weak var searchFeedbackLabel: UILabel!
    
    /// The search feedback view bottom constraint.
    @IBOutlet weak var searchFeedbackViewBottomConstraint: NSLayoutConstraint!
    
    /// Show/hide the search feedback view.
    ///
    /// - Parameter show: Whether to show or hide it.
    func setSearchFeedbackView(with text: String?) {
        let show = text != nil
        
        // update text
        if let text = text {
            searchFeedbackLabel.text = text
        }
        
        // view height
        searchFeedbackView.layoutIfNeeded()
        let height = searchFeedbackView.frame.height
        searchFeedbackViewBottomConstraint.constant = show ? 0 : (-height)
        view.setNeedsUpdateConstraints()
        
        // animate bottom anchor
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    
    // MARK: - Notifications
    
    /// Register for notifications.
    private func setupNotifications() {
        // keyboard show/hide notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyBoardDidShow(notification: NSNotification) {
        if let keyBoardSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            bottomOffset = keyBoardSize.height
        }
    }
    
    @objc func keyBoardWillHide(notification: NSNotification) {
        bottomOffset = 0
    }
    
    
    // MARK: - Helper
    
    /// Adds a top border to the specified view.
    ///
    /// - Parameter view: A view.
    private func addTopBorder(to view: UIView) {
        view.clipsToBounds = true
        let topBorder = CALayer()
        topBorder.borderColor = (UIColor(named: "Separator") ?? UIColor.lightGray).cgColor
        topBorder.borderWidth = 0.5
        topBorder.frame = CGRect(x: 0, y: topBorder.borderWidth, width: view.frame.width, height: topBorder.borderWidth)
        view.layer.addSublayer(topBorder)
    }
    
}
