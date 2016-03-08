//
//  FeedCell.swift
//  Rike
//
//  Created by Mike Weng on 2/22/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation
import UIKit

class FeedCell: UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var toolBar: UIToolbar!

    @IBOutlet weak var rikeButton: UIButton!
    
    @IBAction func rikeTouchUp(sender: AnyObject) {
    }
    @IBAction func commentTouchUp(sender: AnyObject) {
    }
    @IBAction func shareTouchUp(sender: AnyObject) {
    }
}
