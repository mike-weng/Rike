//
//  SelectChatFriendsViewController.swift
//  Rike
//
//  Created by Mike Weng on 2/27/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class SelectChatFriendsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension SelectChatFriendsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Convenience.friendList.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath)
        let friend = Convenience.friendList[indexPath.row] as! PFUser
        cell.textLabel?.text = friend["name"] as? String
        cell.detailTextLabel?.text = friend["username"] as? String
        cell.imageView!.image = UIImage(named: "placeHolder")
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
        let chatRoomViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChatRoomViewController") as! ChatRoomViewController
        let chosenUser = Convenience.friendList[indexPath.row] as! PFUser
        let previousViewController = getPreviousViewController() as! ChatsViewController

        if chatExists(previousViewController.chats, user1: Convenience.currentUser, user2: chosenUser) {
            
            self.dismissViewControllerAnimated(true) { () -> Void in
                chatRoomViewController.user = chosenUser
                
                previousViewController.navigationController?.pushViewController(chatRoomViewController, animated: true)
            }
            
        } else {
            let chat = PFObject(className: "Chat")
            chat.setObject(Convenience.currentUser, forKey: "FromUser")
            chat.setObject(chosenUser, forKey: "ToUser")
            
            chat.saveInBackgroundWithBlock { (success, error) -> Void in
                if success {
                    let relation = Convenience.currentUser.relationForKey("Chat")
                    relation.addObject(chat)
                    Convenience.currentUser.saveInBackgroundWithBlock { (success, error) -> Void in
                        if success {
                            self.dismissViewControllerAnimated(true) { () -> Void in
                                chatRoomViewController.user = chosenUser
                                previousViewController.navigationController?.pushViewController(chatRoomViewController, animated: true)
                            }
                        } else {
                            Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
                        }
                    }
                } else {
                    Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
                }
            }

        }

    }
    
    func getPreviousViewController() -> UIViewController {
        let tabBarController = self.presentingViewController as! UITabBarController
        let navigationController = tabBarController.selectedViewController as! UINavigationController
        let previousViewController = navigationController.viewControllers.first as! ChatsViewController
        return previousViewController
    }
    
    func chatExists(chats: [PFObject], user1: PFUser, user2: PFUser) -> Bool {
        for chat in chats {
            let fromUser = chat["FromUser"] as! PFUser
            let toUser = chat["ToUser"] as! PFUser
            if ((fromUser == user1) && (toUser == user2)) || ((fromUser == user2) && (toUser == user1)) {
                return true
            }
        }
        return false
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
