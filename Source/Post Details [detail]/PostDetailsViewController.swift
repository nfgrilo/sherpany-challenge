//
//  PostDetailsViewController.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 13/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

class PostDetailsViewController: UIViewController, Storyboarded {
    
    /// Weak reference to parent coordinator.
    weak var coordinator: PostDetailsCoordinator?
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    /// Post.
    var post: Post? {
        didSet {
            configureView()
        }
    }
    
    /// Called after view has been loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    /// Update the UI for the post.
    func configureView() {
        // no post?
        guard let post = post else {
            // TODO: show "no selection" view
            DispatchQueue.main.async { [weak self] in
                self?.detailDescriptionLabel.text = "No Post Selected"
            }
            return
        }
        
        // show post
        DispatchQueue.main.async { [weak self] in
            self?.detailDescriptionLabel.text = "Post: id = \(post.id)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

