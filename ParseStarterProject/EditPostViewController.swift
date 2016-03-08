//
//  EditPostViewController.swift
//  Rike
//
//  Created by Mike Weng on 2/21/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse


class EditPostViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var pageIndicator: UIPageControl!
    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Convenience.configureActivityIndicator(self)
        configureTapRecognizer()
        
        
        // Do any additional setup after loading the view.
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

    @IBAction func postTouchUp(sender: AnyObject) {
        Convenience.startActivityIndicator()
        let pageViewController = self.childViewControllers[0] as! PageViewController
        var imageData: NSData
        if pageViewController.currentPage == 0 {
            let contentViewController = pageViewController.postOptions[pageViewController.currentPage] as! AlbumViewController
            imageData = UIImageJPEGRepresentation(contentViewController.imageView.image!, 0.5)!
        } else {
            let contentViewController = pageViewController.postOptions[pageViewController.currentPage] as! CameraViewController
            imageData = UIImageJPEGRepresentation(contentViewController.imageView.image!, 0.5)!
        }
        
        postToParse(imageData)
        
    }
    
    func postToParse(imageData: NSData) {
        let post = PFObject(className: "Post")
        let postRelation = post.relationForKey("User")
        
        postRelation.addObject(Convenience.currentUser)
        let imageFile = PFFile(data: imageData)
        post["imageFile"] = imageFile
        post["caption"] = textField.text
        post["name"] = Convenience.currentUser["name"] as! String
        post["username"] = Convenience.currentUser["username"] as! String
        
        let userRelation = Convenience.currentUser.relationForKey("Post")
        userRelation.addObject(post)
        post.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                Convenience.currentUser.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    } else {
                        Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
                    }
                })
            } else {
                Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
            }
            Convenience.stopActivityIndicator()
        })
    }
    
    @IBAction func pageIndicatorTouchUp(sender: UIPageControl) {

    }
    
    func configureTapRecognizer() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    

}

extension EditPostViewController {
    
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
