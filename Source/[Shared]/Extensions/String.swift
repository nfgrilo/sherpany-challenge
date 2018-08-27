//
//  String.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 27/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation

extension String {
    
    /// Returns a string copy with the first letter capitalized.
    var firstLetterCapitalized: String {
        return prefix(1).uppercased() + dropFirst()
    }
    
}
