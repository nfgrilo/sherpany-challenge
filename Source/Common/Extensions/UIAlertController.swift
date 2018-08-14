//
//  UIAlertController.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

extension UIAlertController {

    /// Convenience method to show an alert style dialog.
    ///
    /// - Parameters:
    ///   - title: The dialog title.
    ///   - message: The dialog description.
    ///   - viewController: The current view controller.
    ///   - completion: Completion closure to be called when dialog is dismissed.
    static func showAlert(with title: String, message: String, on viewController: UIViewController, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        }
        alertController.addAction(action)
        viewController.present(alertController, animated: true, completion: nil)
    }

}
