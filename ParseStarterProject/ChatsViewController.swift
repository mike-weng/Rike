//
//  ChatsViewController.swift
//  Rike
//
//  Created by Mike Weng on 2/27/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class ChatsViewController: UIViewController {
    var chats = [PFObject]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.02, green: 0.02, blue: 0.53, alpha: 1.0)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        loadChats()
    }
    
    @IBAction func startNewChatTouchUp(sender: AnyObject) {
        let selectChatFriendsNavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("SelectChatFriendsNavigationController") as! UINavigationController
        self.presentViewController(selectChatFriendsNavigationController, animated: true, completion: nil)
    }
    
    func loadChats() {
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [NSPredicate(format: "FromUser = %@", Convenience.currentUser), NSPredicate(format: "ToUser = %@", Convenience.currentUser)])
        
        let query = PFQuery(className: "Chat", predicate: predicate)
        query.orderByDescending("updatedAt")
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if let result = result {
                self.chats = result
                self.tableView.reloadData()
            } else {
                Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
            }
        }
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

extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chats.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell", forIndexPath: indexPath)
        let chat = chats[indexPath.row]
        
        var user = chat["ToUser"] as! PFUser
        
        if user == Convenience.currentUser {
            user = chat["FromUser"] as! PFUser
        }
        
        cell.textLabel?.text = user["name"] as? String
        
        if let profilePicture = user["profilePicture"] {
            let imageFile = profilePicture as! PFFile
            imageFile.getDataInBackgroundWithBlock { (result, error) -> Void in
                if let imageData = result {
                    cell.imageView!.image = UIImage(data: imageData)
                } else {
                    Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let chatRoomViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChatRoomViewController") as! ChatRoomViewController
        
        let chat = chats[indexPath.row]
        var user = chat["ToUser"] as! PFUser
        if user == Convenience.currentUser {
            user = chat["FromUser"] as! PFUser
        }

        chatRoomViewController.user = user
        chatRoomViewController.channel = chat.valueForKey("Channel") as! String
        self.navigationController?.pushViewController(chatRoomViewController, animated: true)
        
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
