/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse
import PubNub
import ParseFacebookUtilsV4
import FBSDKCoreKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        Convenience.configureActivityIndicator(self)
        configureTapRecognizer()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    

    override func viewDidAppear(animated: Bool) {
        autoLogin()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func loginTouchUp(sender: AnyObject) {
        if usernameTextField.text == "" || passwordTextField.text == "" {
            Convenience.showAlert(self, title: "Error: empty username/passwords", message: "Please enter username and passwords")
        } else {
            Convenience.startActivityIndicator()
            
            PFUser.logInWithUsernameInBackground(usernameTextField.text!, password: passwordTextField.text!, block: { (user: PFUser?, error: NSError?) in
                
                if user != nil {
                    Convenience.currentUser = user
                    self.appDelegate.configuration?.uuid = Convenience.currentUser.objectId!
                    let tabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                    self.presentViewController(tabBarController, animated: true, completion: nil)
                } else {
                    let errorMsg = error!.userInfo["error"] as? String
                    Convenience.showAlert(self, title: "Failed Login", message: errorMsg!)
                }
                Convenience.stopActivityIndicator()
            })
        }
    }
    @IBAction func loginWithFacebookTouchUp(sender: AnyObject) {
        Convenience.startActivityIndicator()
        let permission = ["public_profile", "user_friends", "email"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permission) { (user, error) -> Void in
            if let user = user {
                Convenience.currentUser = user
                if user.isNew {
                    self.getFBUserInfo()
                }
                let tabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                self.presentViewController(tabBarController, animated: true, completion: nil)
            } else {
                Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
            }
            Convenience.stopActivityIndicator()
        }
        
    }
    
    @IBAction func signUpTouchUp(sender: AnyObject) {
        let signUpViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SignUpViewController") as! SignUpViewController
        self.presentViewController(signUpViewController, animated: true, completion: nil)
    }
    
    func autoLogin() {
        if PFUser.currentUser()?.objectId != nil {
            Convenience.currentUser = PFUser.currentUser()
            let tabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
            self.presentViewController(tabBarController, animated: true, completion: nil)
        }
    }
    
    func getFBUserInfo() {
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "name, email"])
        graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
            if let result = result {
                Convenience.currentUser["name"] = result["name"] as! String
                Convenience.currentUser["email"] = result["email"] as! String
                let userID = result["id"] as! String
                self.getFBProfilePicture(userID)
                print(Convenience.currentUser["profilePicture"])

                Convenience.currentUser.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        
                    } else {
                        Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
                    }
                })
            } else {
                Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
            }
        }
    }
    
    func getFBProfilePicture(userID: String) {
        let urlString = "https://graph.facebook.com/" + userID + "/picture?type=large"
        if let url = NSURL(string: urlString) {
            if let data = NSData(contentsOfURL: url) {
                if let file = PFFile(data: data) {
                    Convenience.currentUser["profilePicture"] = file
                    
                }
            }
        }
    }
    
    func configureTapRecognizer() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
}

extension LoginViewController {
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
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
            lastKeyboardOffset = getKeyboardHeight(notification) / 3
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
