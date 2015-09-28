//
//  ViewController.swift
//  On The Map
//
//  Created by Chris Bacon on 2015-09-26.
//  Copyright © 2015 BaconCo. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        getPins()
        
    }
    
    func getPins(){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Is the "results" key in parsedResult? */
            guard let results = parsedResult["results"] as? [[String : AnyObject]] else {
                print("Cannot find key 'results' in \(parsedResult)")
                return
            }
            
            for pin in results{
                
                let coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin["latitude"] as! Double!), longitude: CLLocationDegrees(pin["longitude"] as! Double!))
                let pinn = MKPointAnnotation()
                
                let first = pin["firstName"] as! String
                let last = pin["lastName"] as! String
                let mediaURL = pin["mediaURL"] as! String
                pinn.title = "\(first) \(last)"
                pinn.subtitle = mediaURL
                
                pinn.coordinate = coordinates
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.addAnnotation(pinn)
                }
            }
        }
        
        task.resume()
    }
    

    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
            
            print("...click click...")
        }
    }

}

