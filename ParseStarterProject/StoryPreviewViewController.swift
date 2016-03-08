//
//  StoryPreviewViewController.swift
//  Rike
//
//  Created by Mike Weng on 2/24/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class StoryPreviewViewController: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func sendButtonTouchUp(sender: AnyObject) {
        let selectFriendsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SelectFriendsViewController") as! SelectFriendsViewController
        selectFriendsViewController.image = image
        self.navigationController?.pushViewController(selectFriendsViewController, animated: true)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
