//
//  APIError.swift
//  Sherpany Posts
//
//  Created by Nuno Grilo on 14/08/2018.
//  Copyright © 2018 NunoGrilo.com. All rights reserved.
//

import Foundation

enum APIError: Error {
    
    /// General error.
    case generalError(message: String)
    
    /// HTTP error.
    case httpError(code: Int)
    
    /// Empty response error.
    case emptyResponse
    
    /// Invalid request error.
    case invalidRequest(message: String)
    
    /// Error description.
    var description: String {
        switch self {
        case .generalError(let message):
            return "Call failed with error \"\(message)\"."
        case .httpError(let code):
            return "Call failed with http error code \"\(code)\"."
        case .emptyResponse:
            return "Call returned an empty response."
        case .invalidRequest(let message):
            return "Invalid request: \"\(message)\"."
        }
    }
    
}
