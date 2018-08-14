//
//  Storyboarded.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 13/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

protocol Storyboarded {
    /// Instantiate whatever class I'm call it on.
    ///
    /// - Returns: returns an instance of class called on.
    static func instantiate() -> Self?
}

extension Storyboarded where Self: UIViewController {
    /// Instantiate a view controller from the 'Main' storyboard on main bundle.
    ///
    /// - Returns: a view controller
    static func instantiate() -> Self? {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".").last ?? fullName
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: className) as? Self
    }
}
