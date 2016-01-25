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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        activityIndicator.startAnimating()
        mapView.alpha = 0.4
        
        Person.sharedInstance.getStudentLocations() { success, errorMessage in
            var annotations = [MKPointAnnotation]()
            if success {
                for location in Person.sharedInstance.locations {
                    let lat = CLLocationDegrees(location.latitude)
                    let long = CLLocationDegrees(location.longitude)
                    
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(location.firstName) \(location.lastName)"
                    annotation.subtitle = location.mediaURL
                    
                    annotations.append(annotation)
                }
            } else {
                //Show error message :(
                
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.alpha = 0
                }
                alert.addAction(dismissAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.mapView.addAnnotations(annotations)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.alpha = 0
                self.mapView.alpha = 1.0
            }
        }
    }
    
    @IBAction func createPin(sender: AnyObject) {
        let infoPostController = self.storyboard?.instantiateViewControllerWithIdentifier("LinkPostViewController") as! LinkPostViewController
        
        self.presentViewController(infoPostController, animated: true, completion: nil)
    }
    
    @IBAction func logout(sender: AnyObject) {
        User.sharedInstance.logout() { success, error in
            if success == true {
                dispatch_async(dispatch_get_main_queue()) {
                    let loginController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    
                }
                alert.addAction(dismissAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.greenColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let url = NSURL(string: annotationView.annotation!.subtitle!!)
            UIApplication.sharedApplication().openURL(url!)
        }
    }
}

