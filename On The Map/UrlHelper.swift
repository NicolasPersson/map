//
//  UrlHelper.swift
//  On The Map
//
//  Created by Chris Bacon on 2016-01-14.
//  Copyright © 2016 BaconCo. All rights reserved.
//

import Foundation


import Foundation

class UrlHelper: NSObject {
    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        var params = [String]()
        for (key, value) in parameters {
            let string = "\(value)"
            let escapedValue = string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            params += [key + "=" + "\(escapedValue!)"]   
        }
        return (!params.isEmpty ? "?" : "") + params.joinWithSeparator("&")
    }
    
    class func parseJSON(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parseError: NSError? = nil

        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parseError = error
            parsedResult = nil
        }
        
        if let error = parseError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
}