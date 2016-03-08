//
//  ParseConvenience.swift
//  Rike
//
//  Created by Mike Weng on 2/22/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation
import UIKit
import Parse

class Convenience {
    static var currentUser: PFUser!
    static var friendList: [PFObject] = []
    static var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    static func showAlert(target: UIViewController, title: String, message: String) {        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        target.presentViewController(alert, animated: true, completion: nil)
    }
    
    static func configureActivityIndicator(target: UIViewController) {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = target.view.center
        activityIndicator.activityIndicatorViewStyle = .Gray
        target.view.addSubview(activityIndicator)
    }
    
    static func startActivityIndicator() {
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()

    }
    
    static func stopActivityIndicator() {
        self.activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
}