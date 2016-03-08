//
//  StoryFriendViewController.swift
//  Rike
//
//  Created by Mike Weng on 2/24/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class SelectFriendsViewController: UIViewController {
    var image: UIImage!
    var usersToBeSent: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSendButton()
        Convenience.configureActivityIndicator(self)
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureSendButton() {
        let sendButton = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Plain, target: self, action: "sendStory")
        self.navigationItem.rightBarButtonItem = sendButton
    }
    
    func sendStory() {
        Convenience.startActivityIndicator()
        
        let story = PFObject(className: "Story")
        let imageData = UIImageJPEGRepresentation(image, 0.5)!
        let imageFile = PFFile(data: imageData)
        
        let fromUserRelation = story.relationForKey("FromUser")
        fromUserRelation.addObject(Convenience.currentUser)
        
        story["imageFile"] = imageFile
        story["name"] = Convenience.currentUser["name"] as! String
        story["username"] = Convenience.currentUser["username"] as! String
        story.ACL?.publicWriteAccess = true
        
        let toUsersRelation = story.relationForKey("ToUsers")
        for user in self.usersToBeSent {
            toUsersRelation.addObject(user as! PFObject)
        }
        
        let userRelation = Convenience.currentUser.relationForKey("Story")
        userRelation.addObject(story)
        
        
        story.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                Convenience.currentUser.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    } else {
                        Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
                    }
                    Convenience.stopActivityIndicator()
                })
            } else {
                Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
            }
            Convenience.stopActivityIndicator()
        })
    }

}

    // MARK: - Table view data source
extension SelectFriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Convenience.friendList.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendsCell", forIndexPath: indexPath)
        let friend = Convenience.friendList[indexPath.row] as! PFUser
        cell.textLabel?.text = friend["name"] as? String
        cell.detailTextLabel?.text = friend["username"] as? String
        cell.imageView!.image = UIImage(named: "placeHolder")
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let friend = Convenience.friendList[indexPath.row] as! PFUser
        tableView.allowsMultipleSelection = true
        
        cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        usersToBeSent.addObject(friend)
        
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let friend = Convenience.friendList[indexPath.row] as! PFUser
        cell?.accessoryType = UITableViewCellAccessoryType.None
        usersToBeSent.removeObject(friend)
    }
    
    /*
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
}
