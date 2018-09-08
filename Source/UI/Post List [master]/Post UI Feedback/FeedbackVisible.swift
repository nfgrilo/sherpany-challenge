//
//  FeedbackVisible.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 08/09/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation

protocol FeedbackVisible: class {
    
    /// Is progress view is visible?
    var isProgressViewVisible: Bool { get set }
    
    /// Search feedback text.
    ///
    /// When set, a new view will appear to show feedback text.
    var searchFeedbackText: String? { get set }
    
}

/// Convenience methods for FeedbackVisible protocol.
extension FeedbackVisible {
    
    /// Show/hide the progress view.
    ///
    /// - Parameter show: Whether to show or hide it.
    func showProgressView(_ show: Bool) {
        isProgressViewVisible = show
    }
    
    /// Show/hide the search feedback view.
    ///
    /// - Parameter show: Whether to show or hide it.
    func setSearchFeedbackView(with text: String?) {
        searchFeedbackText = text
    }
    
}
