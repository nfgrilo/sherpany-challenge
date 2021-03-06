//
//  PostUIFeedbackViewController.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 25/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

// Requirement #12: ✅ (UI feedback)

class PostUIFeedbackViewController: UIViewController, Storyboarded {
    
    /// Text feedback view.
    @IBOutlet weak var textFeedbackView: UIView!
    
    /// Label from text feedback view.
    @IBOutlet weak var textFeedbackLabel: UILabel!
    
    /// Progress view.
    @IBOutlet weak var progressView: UIView!
    
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Attach to other view controller.
    ///
    /// UI Feedback view will be placed at the bottom.
    ///
    /// - Parameter viewController: The "hosting" view controller.
    func attachTo(_ viewController: UIViewController) {
        // load view if needed
        loadViewIfNeeded()
        
        // add to vc & view hiearchy
        viewController.addChildViewController(self)
        viewController.view.addSubview(view)
        let hostingView: UIView = viewController.view
        self.hostingView = hostingView
        
        // top border
        backgroundView.clipsToBounds = true
        let topBorder = CALayer()
        topBorder.borderColor = (UIColor(named: "Separator") ?? UIColor.lightGray).cgColor
        topBorder.borderWidth = 0.5
        topBorder.frame = CGRect(x: 0, y: topBorder.borderWidth, width: view.frame.width, height: topBorder.borderWidth)
        backgroundView.layer.addSublayer(topBorder)
        
        // layout
        //  -> anchors
        let views: [String: Any] = ["view": view]
        hostingView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views))
        //  -> bottom constraint
        backgroundViewBottomConstraint = hostingView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: CGFloat(0))
        backgroundViewBottomConstraint?.isActive = true
        
        // initial setup
        adjustLayout()
        
        // register for notifications
        setupNotifications()
    }
    
    /// Superview where view is addded.
    private weak var hostingView: UIView?
    
    /// The background view with visual effect (blur).
    @IBOutlet weak var backgroundView: UIVisualEffectView!
    
    /// Text feedback view.
    @IBOutlet weak var textFeedback: UIView!
    
    /// Loading/refreshing feedback view.
    @IBOutlet weak var loadingFeedback: UIView!
    
    
    // MARK: - Show/Hide feedback
    
    /// Show/hide the search feedback view.
    var isProgressViewVisible: Bool = false {
        didSet {
            adjustLayout()
        }
    }
    
    /// Search feedback text.
    var searchFeedbackText: String? = nil {
        didSet {
            // update text
            if let text = searchFeedbackText {
                textFeedbackLabel.text = text
            }
            
            adjustLayout()
        }
    }
    
    /// Is search feedback visible?
    var isTextFeedbackViewVisible: Bool {
        return searchFeedbackText != nil
    }
    
    
    /// Layout and animate background view and its children.
    private func adjustLayout() {
        guard let hostingView = self.hostingView else { return }
        let isBackgroundViewHidden = !isProgressViewVisible && !isTextFeedbackViewVisible

        // background view
        view.layoutIfNeeded()
        let backgroundViewHeight = backgroundView.frame.height
        backgroundViewBottomConstraint?.constant = bottomOffset + (isBackgroundViewHidden ? -backgroundViewHeight : 0)
        
        // text feedback view
        let textFeedbackHeight = textFeedbackView.frame.height
        textFeedbackBottomConstraint?.constant = isTextFeedbackViewVisible ? 0 : -textFeedbackHeight
        
        // progress view
        let progressHeight = progressView.frame.height
        progressBottomConstraint?.constant = isProgressViewVisible ? 0 : -progressHeight
        
        // animate background view bottom anchor & feedback views
        let backgroundViewAlpha: CGFloat = isBackgroundViewHidden ? 0 : 1
        let textFeedbackViewAlpha: CGFloat = isTextFeedbackViewVisible ? 1 : 0
        let progressViewAlpha: CGFloat = isProgressViewVisible ? 1 : 0
        hostingView.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.textFeedbackView.alpha = textFeedbackViewAlpha
            self?.progressView.alpha = progressViewAlpha
            self?.backgroundView.alpha = backgroundViewAlpha
            hostingView.layoutIfNeeded()
        }
    }
    
    /// The bottom constraint on the background view.
    private var backgroundViewBottomConstraint: NSLayoutConstraint?
    
    /// The bottom constraint on the text feedback view (attached/behind loading view).
    @IBOutlet weak var textFeedbackBottomConstraint: NSLayoutConstraint!
    
    /// The bottom constraint on the progress view.
    @IBOutlet weak var progressBottomConstraint: NSLayoutConstraint!
    
    /// The bottom offset.
    ///
    /// This value can be different from 0 (zero) if keyboard is shown.
    private var bottomOffset: CGFloat = 0 {
        didSet {
            adjustLayout()
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
    
}
