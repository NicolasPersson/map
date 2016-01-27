//
//  LinkPostViewController.swift
//  On The Map
//
//  Created by Chris Bacon on 2015-10-18.
//  Copyright © 2015 BaconCo. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBook
import MapKit

class LinkPostViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    let geocoder: CLGeocoder = CLGeocoder()
    
    @IBOutlet weak var pointMap: MKMapView!
    @IBOutlet weak var linkInput: UITextField!
    @IBOutlet weak var debugText: UILabel!
    @IBOutlet weak var locationInput: UITextField!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var objectId: String?
    var oldMapString: String?
    var oldMediaURL: String?
    
    var mapString: String?
    var mediaURL: String?
    var latitude: Double?
    var longitude: Double?
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Configure the UI */
        self.configureUI()
        
        self.linkInput.delegate = self;
        self.locationInput.delegate = self;
    }
    
    override func viewWillAppear(animated: Bool) {
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
        
        Person.sharedInstance.queryStudentLocation(User.sharedInstance.userID!) { results, error in
            if let locations = results {
                if locations.count > 0 {
                    self.objectId = locations[0].objectId
                    self.oldMapString = locations[0].mapString
                    self.oldMediaURL = locations[0].mediaURL
                    
                    let alert = UIAlertController(title: "Override?", message: "You already have a pin on the map do you want to override it?", preferredStyle: .Alert)
                    let updateAction = UIAlertAction(title: "Override", style: .Default) { (action) in
                        self.locationInput.text = self.oldMapString
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action) in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alert.addAction(updateAction)
                    alert.addAction(cancelAction)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                }
            } else {
                print(error)
            }
            
        }
    }
    
    func submitLocation() {
        if let url = NSURL(string: linkInput.text!) {
            mediaURL = linkInput.text
            
            let locationData: [String: AnyObject] = [
                Person.JSONResponseKeys.uniqueKey: User.sharedInstance.userID!,
                Person.JSONResponseKeys.firstName: User.sharedInstance.name!.first,
                Person.JSONResponseKeys.lastName: User.sharedInstance.name!.last,
                Person.JSONResponseKeys.mapString: mapString!,
                Person.JSONResponseKeys.mediaURL: mediaURL!,
                Person.JSONResponseKeys.latitude: latitude!,
                Person.JSONResponseKeys.longitude: longitude!
            ]
            
            activityIndicator.startAnimating()
            pointMap.alpha = 0.5
            
            if let id = objectId{
                Person.sharedInstance.putStudentLocation(id, data: locationData) { success, errorMessage in
                    self.postComplete( success, errorMessage: errorMessage )
                }
            } else {
                Person.sharedInstance.postStudentLocation(locationData) { success, errorMessage in
                    self.postComplete( success, errorMessage: errorMessage )
                }
            }
            
        } else {
            print("Please enter a valid URL")
        }
    }
    
    func findOnMap(location: String) {
        activityIndicator.startAnimating()
        geocoder.geocodeAddressString(location) { placemarks, error in
            if error == nil {
                if let placemark = placemarks![0] as CLPlacemark? {
                    let coordinates = placemark.location!.coordinate
                
                    self.latitude = coordinates.latitude as Double
                    self.longitude = coordinates.longitude as Double
                    self.mapString = location
                    
                    let region = MKCoordinateRegionMake(coordinates, MKCoordinateSpanMake(0.5, 0.5))
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinates
                    self.pointMap.addAnnotation(annotation)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.alpha = 0
                                               
                        if self.oldMediaURL != nil {
                            self.linkInput.text = self.oldMediaURL
                        } else {
                            self.linkInput.text = "Enter URL"
                        }
                        self.postButton.setTitle("Submit", forState: .Normal)
                        
                        self.pointMap.alpha = 1.0
                        self.pointMap.setRegion(region, animated: true)
                    }
                }
            } else {
                let alert = UIAlertController(title: "Can't get there from here.", message: "Sorry we couldn't find that location.", preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    self.locationInput.text = ""
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.alpha = 0
                }
                alert.addAction(dismissAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    func postComplete( success: Bool, errorMessage: String? ) {
        if success {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
            let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
            alert.addAction(dismissAction)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.pointMap.alpha = 1.0
            self.activityIndicator.stopAnimating()
            self.activityIndicator.alpha = 0
        }
    }
    
    @IBAction func cancelSubmission(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func submit(sender: AnyObject) {
        locationInput.endEditing(false)
        if mapString == nil {
            findOnMap(locationInput.text!)
        } else {
            submitLocation()
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        submit(self)
        return true
    }
        
}

/* This code has been added in response to student comments */
extension LinkPostViewController {
    func configureUI() {
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    

}

