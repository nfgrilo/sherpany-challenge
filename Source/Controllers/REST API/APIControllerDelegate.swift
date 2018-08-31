//
//  APIControllerDelegate.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 31/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation

protocol APIControllerDelegate {
    
    /// Informs delegate that an API resource will be fetched.
    func willFetchResource(with: URL)
    
    /// Informs delegate that an API resource was fetched.
    func didFetchResource(with: URL)
    
}
