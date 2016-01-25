//
//  TableViewController.swift
//  On The Map
//
//  Created by Chris Bacon on 2015-09-27.
//  Copyright © 2015 BaconCo. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func viewWillAppear(animated: Bool) {
        
        Person.sharedInstance.getStudentLocations() { success, errorMessage in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            } else {
                //Display error message
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    
                }
                alert.addAction(dismissAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    @IBAction func addPin(sender: AnyObject) {
        let infoPostController = self.storyboard?.instantiateViewControllerWithIdentifier("LinkPostViewController") as! LinkPostViewController
        
        self.presentViewController(infoPostController, animated: true, completion: nil)
    }
    
    @IBAction func logOut(sender: AnyObject) {
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)! as UITableViewCell
        
        let location = Person.sharedInstance.locations[indexPath.row]
        
        cell.textLabel?.text = "\(location.firstName) \(location.lastName)"
        cell.detailTextLabel?.text = location.mediaURL
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Person.sharedInstance.locations.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = Person.sharedInstance.locations[indexPath.row]
        
        let app = UIApplication.sharedApplication()
        if let url = NSURL(string: location.mediaURL) {
            app.openURL( url )
        } else {
            print("ERROR: Invalid url")
        }
    }
    
    
}


