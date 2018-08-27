//
//  PostAlbumHeaderView.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 21/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

protocol PostAlbumHeaderViewDelegate {
    /// Called when user taps on header view.
    ///
    /// - Parameters:
    ///   - collectionView: The parent collection view.
    ///   - headerTapped: The header view that was tapped.
    ///   - section: Collection view section index.
    func tableView(collectionView: UICollectionView?, headerTapped: PostAlbumHeaderView, section: Int?)
}

class PostAlbumHeaderView: UICollectionReusableView {
    
    /// Album title header view identifier.
    static let viewIdentifier = "PostAlbumHeaderView"
    
    /// Header title (album title).
    var title: String? {
        didSet {
            titleLabel.text = title ?? "(untitled album)"
        }
    }
    
    /// Is header collapsed?
    var isCollapsed: Bool = false {
        didSet {
            collapseLabel.text = isCollapsed ? "+" : "-"
            
            if let collapsedColor = UIColor(named: "Album Title Background"),
                let expandedColor = UIColor(named: "Album Title Background Highlighted") {
                backgroundView.backgroundColor = isCollapsed ? collapsedColor : expandedColor
            }
        }
    }
    
    /// Table view section index.
    var section: Int?
    
    /// Header height.
    static let headerHeight: CGFloat = 40
    
    /// Weak reference to parent collection view.
    weak var collectionView: UICollectionView?
    
    /// The delegate to be informed when header is tapped.
    var delegate: PostAlbumHeaderViewDelegate?
    
    /// Label for album title.
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Label for collpasing/expanding.
    @IBOutlet weak var collapseLabel: UILabel!
    
    /// Background view.
    @IBOutlet weak var backgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    /// Configures the headers.
    ///
    /// - Parameters:
    ///   - title: The section title
    ///   - isCollapsed: Starts collapsed?
    ///   - sectionIndex: The section index.
    ///   - tableView: The parent table view.
    ///   - delegate: The delegate.
    func configure(with title: String?, isCollapsed: Bool, section: Int?, collectionView: UICollectionView?, delegate: PostAlbumHeaderViewDelegate?) {
        self.title = title
        self.isCollapsed = isCollapsed
        self.section = section
        self.collectionView = collectionView
        self.delegate = delegate
    }
    
    /// Setup the views.
    private func setup() {
        // add tap gesture
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:))))
    }
    
    /// Called when user taps header.
    ///
    /// - Parameter gestureRecognizer: The associated gesture recognizer.
    @objc func headerTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.tableView(collectionView: collectionView, headerTapped: self, section: section)
    }
    
}
