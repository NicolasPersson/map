//
//  LoginViewController.swift
//  On The Map
//
//  Created by Chris Bacon on 2015-09-28.
//  Copyright © 2015 BaconCo. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var debugText: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!

    var backgroundGradient: CAGradientLayer? = nil
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    /* Based on student comments, this was added to help with smaller resolution devices */
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Configure the UI */
        self.configureUI()
        
        self.usernameInput.delegate = self;
        self.passwordInput.delegate = self;
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
        
        activityIndicator.hidesWhenStopped = true
        self.passwordInput.text = ""
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }
    @IBAction func logIn(sender: AnyObject) {
        startNetworkActivity()
        debugText.hidden = true
        
        User.sharedInstance.loginWithUsername( usernameInput.text!, password: passwordInput.text!) { (success, error) in
            
            if success {
                // Let's get this party started!
                dispatch_async(dispatch_get_main_queue()) {
                    self.stopNetworkActivity()
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabView") as! UITabBarController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            } else {

                if error == User.Errors.loginError {
                    // Wrong username or password. Booo!!!!
                    let alert = UIAlertController(title: "Error", message: "Wrong username or password. Booo", preferredStyle: UIAlertControllerStyle.Alert)
                    let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
                    alert.addAction(dismissAction)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    self.passwordInput.text = ""
                } else {
                    let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
                    alert.addAction(dismissAction)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.stopNetworkActivity()
                }
            }
        }
    }
    
    func startNetworkActivity() {
        activityIndicator.startAnimating()
        loginButton.hidden = true
        usernameInput.userInteractionEnabled = false
        passwordInput.userInteractionEnabled = false
    }
    
    func stopNetworkActivity() {
        activityIndicator.stopAnimating()
        loginButton.hidden = false
        usernameInput.userInteractionEnabled = true
        passwordInput.userInteractionEnabled = true
    }
}

// MARK: - LoginViewController (Configure UI)

extension LoginViewController {
    
    func setUIEnabled(enabled enabled: Bool) {
        usernameInput.enabled = enabled
        passwordInput.enabled = enabled
        loginButton.enabled = enabled
        debugText.enabled = enabled
        
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    func configureUI() {
        
        /* Configure background gradient */
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).CGColor
        self.backgroundGradient = CAGradientLayer()
        self.backgroundGradient!.colors = [colorTop, colorBottom]
        self.backgroundGradient!.locations = [0.0, 1.0]
        self.backgroundGradient!.frame = view.frame
        self.view.layer.insertSublayer(self.backgroundGradient!, atIndex: 0)
        
        /* Configure email textfield */
        let emailTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let emailTextFieldPaddingView = UIView(frame: emailTextFieldPaddingViewFrame)
        usernameInput.leftView = emailTextFieldPaddingView
        usernameInput.leftViewMode = .Always
        usernameInput.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        usernameInput.backgroundColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        usernameInput.textColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        usernameInput.attributedPlaceholder = NSAttributedString(string: usernameInput.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        usernameInput.tintColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        
        /* Configure password textfield */
        let passwordTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let passwordTextFieldPaddingView = UIView(frame: passwordTextFieldPaddingViewFrame)
        passwordInput.leftView = passwordTextFieldPaddingView
        passwordInput.leftViewMode = .Always
        passwordInput.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        passwordInput.backgroundColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        passwordInput.textColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        passwordInput.attributedPlaceholder = NSAttributedString(string: passwordInput.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordInput.tintColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
    }
}

// MARK: - LoginViewController (Show/Hide Keyboard)

/* This code has been added in response to student comments */
extension LoginViewController {
    
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

