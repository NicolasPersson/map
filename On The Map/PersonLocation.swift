//
//  PersonLocation.swift
//  On The Map
//
//  Created by Chris Bacon on 2016-01-22.
//  Copyright © 2016 BaconCo. All rights reserved.
//

import Foundation

struct PersonLocation: CustomStringConvertible {
    var objectId: String
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Float
    var longitude: Float
    
    var description: String {
        return "PersonLocation: \(objectId)-\(uniqueKey)"
    }
    
    init( dictionary: [String : AnyObject] ) {
        objectId = dictionary[Person.JSONResponseKeys.objectId] as! String
        uniqueKey = dictionary[Person.JSONResponseKeys.uniqueKey] as! String
        firstName = dictionary[Person.JSONResponseKeys.firstName] as! String
        lastName = dictionary[Person.JSONResponseKeys.lastName] as! String
        mapString = dictionary[Person.JSONResponseKeys.mapString] as! String
        mediaURL = dictionary[Person.JSONResponseKeys.mediaURL] as! String
        latitude = dictionary[Person.JSONResponseKeys.latitude] as! Float
        longitude = dictionary[Person.JSONResponseKeys.longitude] as! Float
    }
    
    static func locationsFromResults(results: [[String : AnyObject]]) -> [PersonLocation] {
        var locations = [PersonLocation]()
        
        for result in results {
            locations.append( PersonLocation(dictionary: result) )
        }
        
        return locations
    }
    
}