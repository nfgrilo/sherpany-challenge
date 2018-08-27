//
//  PostDetailsHeaderView.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 22/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostDetailsHeaderView: UICollectionReusableView {
    
    /// Reusable view identifier.
    static let viewIdentifier = "PostDetailsHeaderView"
    
    /// View-model.
    var model: Model? {
        didSet {
            guard let model = model else {
                postTitle.text = ""
                postBody.text = ""
                postAlbums.text = ""
                return
            }

            // update UI
            postTitle.text = model.title
            postBody.text = model.body
            postAlbums.text = model.hasAlbums ? "Albums" : "No Albums"
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /// View setup.
    private func setup() {
        // color
        backgroundColor = UIColor(named: "Post Details") ?? .clear
        
        // add views
        addSubview(postTitle)
        addSubview(postBody)
        addSubview(postAlbumsView)

        // layout
        let views: [String: Any] = ["title": postTitle,
                                    "body": postBody,
                                    "albums": postAlbumsView]
        let options: NSLayoutFormatOptions = []
        let metrics: [String: Any] = ["top": viewInsets.top,
                                      "left": viewInsets.left,
                                      "bottom": viewInsets.bottom,
                                      "right": viewInsets.right]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[title]-10-[body]-40@750-[albums]|", options: options, metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-left-[title]-right@750-|", options: options, metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-left-[body]-right@750-|", options: options, metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[albums]-0@750-|", options: options, metrics: metrics, views: views))
    }
    
    /// View margins.
    let viewInsets: UIEdgeInsets = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)

    /// Post title label.
    lazy var postTitle: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = UIColor(named: "Post Title") ?? .darkText
        label.numberOfLines = 0
        return label
    }()

    /// Post body label.
    lazy var postBody: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = UIColor(named: "Post Body") ?? .darkGray
        label.numberOfLines = 0
        return label
    }()

    /// Albums label.
    lazy var postAlbums: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textColor = UIColor(named: "Albums") ?? .darkText
        label.numberOfLines = 1
        return label
    }()
    
    /// Albums View.
    lazy var postAlbumsView: UIView = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "Albums Background") ?? .darkText
        view.addSubview(postAlbums)
        // layout
        let views: [String: Any] = ["label": postAlbums]
        let metrics: [String: Any] = ["top": viewInsets.top,
                                      "left": viewInsets.left,
                                      "bottom": viewInsets.bottom,
                                      "right": viewInsets.right]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-left-[label]-right-|", options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[label]-bottom-|", options: [], metrics: metrics, views: views))
        return view
    }()
    
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        // define label's max width so height can be calculated
        for view in subviews.reversed() where view is UILabel {
            (view as? UILabel)?.preferredMaxLayoutWidth = targetSize.width - viewInsets.left - viewInsets.right
        }
        
        // layout
        setNeedsLayout()
        layoutIfNeeded()
        
        return super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    }
    
}

/// Posts details header view-model.
extension PostDetailsHeaderView {
    struct Model {
        let title: String
        let body: String
        let hasAlbums: Bool
        
        init(post: Post) {
            title = post.title ?? "(untitled post)"
            body = post.body ?? ""
            hasAlbums = post.user?.albums.count ?? 0 > 0
        }
    }
}
