//
//  Person.swift
//  On The Map
//
//  Created by Chris Bacon on 2015-09-27.
//  Copyright © 2015 BaconCo. All rights reserved.
//

import UIKit

struct Person {
    
    // MARK: Properties
    
    var firstName = ""
    var lastName = ""
    var mediaURL = ""
    
    var latitude: Double? = nil
    var longitude: Double? = nil
    
    // MARK: Initializers
    
    init(dictionary: [String : AnyObject]) {
        
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        mediaURL = dictionary["mediaURL"] as! String
        
        latitude = dictionary["latitude"] as? Double
        longitude = dictionary["longitude"] as? Double
    }
    
    static func peopleFromResults(results: [[String : AnyObject]]) -> [Person] {
        
        var people = [Person]()
        
        /* Iterate through array of dictionaries; each Movie is a dictionary */
        for result in results {
            people.append(Person(dictionary: result))
        }
        
        return people
    }
    
}
