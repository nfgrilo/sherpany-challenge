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
protocol BaseCoordinator {
    
    /// Child coordinators.
    var childCoordinators: [Coordinator] { get set }
    
    /// Make the coordinator take control.
    func start()
    
}


/// Base class to be subclassed by other coordinators.
class Coordinator: NSObject, BaseCoordinator {
    
    func start() {}
    
    
    // MARK: - Child coordinators
    
    internal var childCoordinators: [Coordinator] = []
    
    public func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    public func removeChild(_ coordinator: Coordinator?) {
        if let coordinator = coordinator, let index = childCoordinators.index(of: coordinator) {
            childCoordinators.remove(at: index)
        }
    }
    
}
