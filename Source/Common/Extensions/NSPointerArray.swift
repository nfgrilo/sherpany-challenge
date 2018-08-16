//
//  NSPointerArray.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 16/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation

extension NSPointerArray {
    
    /// Adds a new pointer to the given object to the array.
    ///
    /// - Parameter object: The object whose pointer will be added.
    func addObject(_ object: AnyObject?) {
        guard let strongObject = object else { return }
        
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        addPointer(pointer)
    }
    
    /// Get an object by its index.
    ///
    /// - Parameter index: The object index in the array.
    /// - Returns: The object, if still exists.
    func object(at index: Int) -> AnyObject? {
        guard index < count, let pointer = self.pointer(at: index) else { return nil }
        return Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue()
    }
    
    /// Removes the pointer that matches the pointer to the given object.
    ///
    /// - Parameter object: The object whose pointer is in the array.
    func removeObject(_ object: AnyObject?) {
        guard let strongObject = object else { return }
        
        // find object pointer
        let objectPointer = Unmanaged.passUnretained(strongObject).toOpaque()
        var objectIndex: Int?
        for i in 0..<count {
            if let pointer = self.pointer(at: i), pointer == objectPointer {
                objectIndex = i
                break
            }
        }
        
        // remove object pointer
        if let index = objectIndex {
            removeObject(at: index)
        }
    }
    
    /// Remove an object by its index.
    ///
    /// - Parameter index: The object index in the array.
    func removeObject(at index: Int) {
        guard index < count else { return }
        
        removePointer(at: index)
    }
    
}
