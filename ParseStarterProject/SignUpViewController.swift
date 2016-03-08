//
//  SignUpViewController.swift
//  Rike
//
//  Created by Mike Weng on 2/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextField2: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!

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
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitTouchUp(sender: AnyObject) {
        

        
        if usernameTextField.text == "" || passwordTextField.text == "" || nameTextField.text == "" || passwordTextField2.text == "" || emailTextField.text == "" || phoneTextField.text == "" {
            Convenience.showAlert(self, title: "Error: empty username/passwords", message: "Please enter username and passwords")
        } else if passwordTextField.text != passwordTextField2.text {
            Convenience.showAlert(self, title: "Error: passwords do not match", message: "Please re-enter your password")
        } else {
            Convenience.startActivityIndicator()
            
            let user = PFUser()
            user.username = usernameTextField.text
            user.password = passwordTextField.text
            user.email = emailTextField.text
            user["name"] = nameTextField.text
            user["phone"] = phoneTextField.text

            user.signUpInBackgroundWithBlock({ (success, error) in
                
                if let error = error {
                    let errorMsg = error.userInfo["error"] as? String
                    Convenience.showAlert(self, title: "Failed Sign Up", message: errorMsg!)
                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                Convenience.stopActivityIndicator()
            })
        }
        passwordTextField.text = ""
        passwordTextField2.text = ""

    }
    @IBAction func loginTouchUp(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func configureTapRecognizer() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    
}



extension SignUpViewController {
    
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


