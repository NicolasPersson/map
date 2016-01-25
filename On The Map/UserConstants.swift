//
//  UserConstants.swift
//  On The Map
//
//  Created by Chris Bacon on 2016-01-14.
//  Copyright © 2016 BaconCo. All rights reserved.
//

import Foundation

extension User {
    
    struct Constants {
        static let BaseURL : String = "https://www.udacity.com/api/"
    }
    
    struct Methods {
        static let Session = "session"
        static let User = "users/"
    }
    
    struct Errors {
        static let loginError = "Login failed. Check username or password"
        static let networkError = "Error trying to connect to network."
    }
    
}