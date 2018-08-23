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
                relatedAlbums.text = ""
                return
            }

            // update UI
            postTitle.text = model.title
            postBody.text = model.body
            relatedAlbums.text = model.hasAlbums ? "Author's Favorite Albums" : "No Favorite Albums"
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
    
    private func setup() {
        // add views
        addSubview(postTitle)
        addSubview(postBody)
        addSubview(relatedAlbums)

        // layout
        let views: [String: Any] = ["title": postTitle,
                                    "body": postBody,
                                    "albumsTitle": relatedAlbums]
        let options: NSLayoutFormatOptions = []
        let metrics: [String: Any] = ["top": viewInsets.top,
                                      "left": viewInsets.left,
                                      "bottom": viewInsets.bottom,
                                      "right": viewInsets.right]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[title]-10-[body]-40@750-[albumsTitle]-bottom-|", options: options, metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-left-[title]-right@750-|", options: options, metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-left-[body]-right@750-|", options: options, metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-left-[albumsTitle]-right@750-|", options: options, metrics: metrics, views: views))
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

    /// Related albums label.
    lazy var relatedAlbums: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textColor = UIColor(named: "Albums") ?? .darkText
        label.numberOfLines = 1
        return label
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
