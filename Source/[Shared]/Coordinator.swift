//
//  Coordinator.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 13/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import UIKit

protocol Coordinator {
    
    /// Child coordinators.
    var childCoordinators: [Coordinator] { get set }
    
    /// Make the coordinator take control.
    func start()
    
}
