//
//  PostAlbumTableViewHeaderView.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 20/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit


protocol PostAlbumTableViewHeaderViewDelegate {
    /// Called when user taps on header view.
    ///
    /// - Parameters:
    ///   - tableView: The parent table view.
    ///   - headerTapped: The header view that was tapped.
    ///   - section: Table view section index.
    func tableView(tableView: UITableView?, headerTapped: PostAlbumTableViewHeaderView, section: Int?)
}


class PostAlbumTableViewHeaderView: UITableViewHeaderFooterView {
    
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
        }
    }
    
    /// Table view section index.
    var section: Int?
    
    /// Header height.
    static let headerHeight: CGFloat = 40
    
    /// Weak reference to parent table view.
    weak var tableView: UITableView?
    
    /// The delegate to be informed when header is tapped.
    var delegate: PostAlbumTableViewHeaderViewDelegate?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    func configure(with title: String?, isCollapsed: Bool, section: Int?, tableView: UITableView?, delegate: PostAlbumTableViewHeaderViewDelegate?) {
        self.title = title
        self.isCollapsed = isCollapsed
        self.section = section
        self.tableView = tableView
        self.delegate = delegate
    }
    
    /// Setup the views.
    private func setup() {
        // use vibrancy for background view
        let blurEffect = UIBlurEffect(style: .extraLight)
        let vibrancyView = UIVisualEffectView(effect: blurEffect)
        backgroundView = vibrancyView
        
        // add title label
        let titleLabel = self.titleLabel
        contentView.addSubview(titleLabel)
        
        // add collapse label
        let collapseLabel = self.collapseLabel
        contentView.addSubview(collapseLabel)
        
        // layout
        let views: [String: Any] = ["title": titleLabel,
                                    "collapseLabel": collapseLabel]
        let metrics: [String: Any] = ["collapseWidth": 32]
        // the higher priority set on the constraints are important,
        // otherwise the layout would become ambiguous when collapsing/expanding
        // albums (tablview adds `UIView-Encapsulated-Layout-Width` and `UIView-Encapsulated-Layout-Height`,
        // despite of using autolayout or not :/)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[title]-(>=20@500)-[collapseLabel(collapseWidth)]-10-|", options: [], metrics: metrics, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[title]-8@500-|", options: [], metrics: metrics, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[collapseLabel]-8@500-|", options: [], metrics: metrics, views: views))
        
        // add tap gesture
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:))))
    }
    
    /// Label for album title.
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        if let albumTitleColor = UIColor(named: "Album Title") {
            label.textColor = albumTitleColor
        }
        label.numberOfLines = 0
        return label
    }()
    
    /// Label for collpasing/expanding.
    private lazy var collapseLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        if let albumTitleColor = UIColor(named: "Album Title") {
            label.textColor = albumTitleColor
        }
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    /// Called when user taps header.
    ///
    /// - Parameter gestureRecognizer: The associated gesture recognizer.
    @objc func headerTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.tableView(tableView: tableView, headerTapped: self, section: section)
    }
    
}
