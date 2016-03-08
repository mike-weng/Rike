////
////  KeyboardController.swift
////  Rike
////
////  Created by Mike Weng on 2/20/16.
////  Copyright © 2016 Parse. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class KeyboardController{
//    
//    let target: UIViewController
//    
//    init(target: UIViewController) {
//        self.target = target
//    }
//    
//    func configureTapRecognizer() {
//        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
//        tapRecognizer?.numberOfTapsRequired = 1
//    }
//
//    
//    
//    func handleSingleTap(recognizer: UITapGestureRecognizer) {
//        self.view.endEditing(true)
//    }
//    
//    func addKeyboardDismissRecognizer() {
//        self.view.addGestureRecognizer(tapRecognizer!)
//    }
//    
//    func removeKeyboardDismissRecognizer() {
//        self.view.removeGestureRecognizer(tapRecognizer!)
//    }
//    
//    func subscribeToKeyboardNotifications() {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
//    }
//    
//    func unsubscribeToKeyboardNotifications() {
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
//    }
//    
//    func keyboardWillShow(notification: NSNotification) {
//        
//        if keyboardAdjusted == false {
//            lastKeyboardOffset = getKeyboardHeight(notification) / 3
//            self.view.superview?.frame.origin.y -= lastKeyboardOffset
//            keyboardAdjusted = true
//        }
//    }
//    
//    func keyboardWillHide(notification: NSNotification) {
//        
//        if keyboardAdjusted == true {
//            self.view.superview?.frame.origin.y += lastKeyboardOffset
//            keyboardAdjusted = false
//        }
//    }
//    
//    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
//        let userInfo = notification.userInfo
//        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
//        return keyboardSize.CGRectValue().height
//    }
//
//}