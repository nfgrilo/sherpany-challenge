//
//  PhotoControllerDelegate.swift
//  Tests
//
//  Created by Nuno Grilo on 31/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation

protocol PhotoControllerDelegate {
    
    /// Informs delegate that a photo will be fetched.
    func willFetchPhoto(with: URL)
    
    /// Informs delegate that a photo was fetched.
    func didFetchPhoto(with: URL)
    
}
