//
//  Person.swift
//  On The Map
//
//  Created by Chris Bacon on 2016-01-22.
//  Copyright © 2016 BaconCo. All rights reserved.
//

import Foundation

class Person: NSObject {
    
    //Singleton
    static let sharedInstance = Person()
    
//    var locations = PersonLocation.sharedInstance.locations
    
    override init() {
        super.init()
    }
    
    
    func requestForMethod( method: String ) -> NSMutableURLRequest {
        let urlString = Constants.BaseURL
        let URL = NSURL(string: urlString)!
        
        return NSMutableURLRequest(URL: URL)
    }
    
    func taskWithRequest( request: NSMutableURLRequest, completionHandler: (results: AnyObject?, error: NSError?) -> Void ) -> NSURLSessionTask {
        
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest( request ) { (data, response, error) in
            if error == nil {
                //Success
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                UrlHelper.parseJSON(data!, completionHandler: completionHandler)
            } else {
                //Error
                completionHandler(results: nil, error: error)
            }
        }
        task.resume()
        return task
    }
    
    func getStudentLocations( completionHandler: (success: Bool, errorMessage: String?) -> Void ) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.BaseURL + "?order=-updatedAt")!)
        
        taskWithRequest(request) { JSONresults, error in
            
            if error == nil {
                if let results = JSONresults?.valueForKey(JSONResponseKeys.results) as? [[String : AnyObject]] {
                    PersonLocation.locationsFromResults(results)
                    completionHandler( success: true, errorMessage: nil )
                } else {
                    completionHandler( success: false, errorMessage: Errors.downloadError )
                }
            } else {
                completionHandler( success: false, errorMessage: Errors.networkError )
            }
        }
    }
    
    func queryStudentLocation( uniqueKey: String, completionHandler: (results: [PersonLocation]?, errorMessage: String?) -> Void ) {
        
        let urlString = "\(Constants.BaseURL)?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        
        taskWithRequest(request) { JSONresults, error in
            if error == nil {
                if let results = JSONresults?.valueForKey(JSONResponseKeys.results) as? [[String : AnyObject]] {
                    let locations = PersonLocation.locationsFromResults(results)
                    completionHandler( results: locations, errorMessage: nil )
                }
            } else {
                completionHandler( results: nil, errorMessage: Errors.downloadError )
            }
        }
    }
    
    func postStudentLocation( data: [String : AnyObject], completionHandler: (success: Bool, errorMessage: String?) -> Void ) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.BaseURL)!)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(data, options: [])
            
                taskWithRequest(request) { JSONresults, error in
                    completionHandler(success: true, errorMessage: nil)
                }
            } catch _ as NSError {
                taskWithRequest(request) { JSONresults, error in
                        completionHandler(success: false, errorMessage: Errors.postError)
                }
        }
    }
    
    func putStudentLocation( objectId: String, data: [String: AnyObject], completionHandler: (success: Bool, errorMessage: String?) -> Void ) {
        
        let urlString = "\(Constants.BaseURL)/\(objectId)"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        request.HTTPMethod = "PUT"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(data, options: [])
            
            taskWithRequest(request) { JSONresults, error in
                completionHandler(success: true, errorMessage: nil)
            }
        } catch _ as NSError {
            taskWithRequest(request) { JSONresults, error in
                completionHandler(success: false, errorMessage: Errors.postError)
            }
        }
    }
    
}

extension Person {
    struct Constants {
        static let BaseURL: String = "https://api.parse.com/1/classes/StudentLocation"
        static let AppID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    struct Errors {
        static let downloadError = "Error downloading student data"
        static let networkError = "Error connecting to server"
        static let postError = "Error posting student location data."
    }
    
    struct JSONResponseKeys {
        //GET and QUERY
        static let results: String = "results"
        static let error: String = "error"
        
        static let objectId: String = "objectId"
        static let uniqueKey: String = "uniqueKey"
        static let firstName: String = "firstName"
        static let lastName: String = "lastName"
        static let mapString: String = "mapString"
        static let mediaURL: String = "mediaURL"
        static let latitude: String = "latitude"
        static let longitude: String = "longitude"
        
        //POST
        static let createdAt: String = "createdAt"
        
        //PUT
        static let updatedAt: String = "updatedAt"
    }
}