//
//  Coordinator.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 13/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

/// Coordinator protocol.
///
/// This is inspired on the great Coordinator pattern by Soroush Khanlou.
/// More info at http://khanlou.com/2015/10/coordinators-redux/
protocol Coordinator {
    
    /// Make the coordinator take control.
    func start()
    
}
