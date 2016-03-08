//
//  StoryResponseViewController.swift
//  Rike
//
//  Created by Mike Weng on 2/26/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class StoryResponseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var story: PFObject!
    var respondedUsers = [[PFObject]]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLikedUsers()
        loadDislikedUsers()
        loadNoCommentUsers()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadLikedUsers() {
        let relation = story.relationForKey("UsersLiked")
        let query = relation.query()
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if let result = result {
                self.respondedUsers.append(result)
                self.tableView.reloadData()
            }  else {
                Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
            }
        }
    
    }
    
    func loadDislikedUsers() {
        let relation = story.relationForKey("UsersDisliked")
        let query = relation.query()
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if let result = result {
                self.respondedUsers.append(result)
                self.tableView.reloadData()
            }  else {
                Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
            }
        }
    }
    
    func loadNoCommentUsers() {
        let relation = story.relationForKey("UsersNoComment")
        let query = relation.query()
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if let result = result {
                self.respondedUsers.append(result)
                self.tableView.reloadData()
            }  else {
                Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
            }
        }
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return respondedUsers.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return respondedUsers[section].count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserHeaderCell") as! UserHeaderCell
        switch section {
        case 0:
            cell.sectionLabel.text = "Liked"
        case 1:
            cell.sectionLabel.text = "Disliked"
        case 2:
            cell.sectionLabel.text = "No Comment"
        default:
            cell.sectionLabel.text = ""
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath)
        let user = respondedUsers[indexPath.section][indexPath.row]
        cell.textLabel?.text = user["name"] as? String
        cell.detailTextLabel?.text = user["username"] as? String
        cell.imageView?.image = UIImage(named: "placeHolder")
        
        return cell
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        
//        let cell = tableView.cellForRowAtIndexPath(indexPath)
//        let friend = Convenience.friendList[indexPath.row] as! PFUser
//        tableView.allowsMultipleSelection = true
//        
//        cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
//        usersToBeSent.addObject(friend)
//        
//        
//    }
    
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

