//
//  TableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Mike Weng on 2/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class FriendsTableViewController: UITableViewController {
    
    var refresher: UIRefreshControl!
    var friendList: [PFObject] = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.addUniqueObject("Giants", forKey: "channels")
        currentInstallation.saveInBackground()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.02, green: 0.02, blue: 0.53, alpha: 1.0)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        Convenience.configureActivityIndicator(self)
        configureRefresher()
        loadFriendsList()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let selectedIndexPath = tableView.indexPathForSelectedRow
        if selectedIndexPath != nil {
            tableView.deselectRowAtIndexPath(selectedIndexPath!, animated: true)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadFriendsList() {
        Convenience.startActivityIndicator()
        let user = Convenience.currentUser
        
        let relation = user?.relationForKey("friends")
        let query = relation?.query()
        query?.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if let result = result {
                self.friendList = result
                Convenience.friendList = result
                self.tableView.reloadData()
            } else {
                Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
            }
            Convenience.stopActivityIndicator()
        })
    }
    
    func refresh() {
        loadFriendsList()
        refresher.endRefreshing()
    }
    
    func configureRefresher() {
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friendList.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendsCell", forIndexPath: indexPath) as! UserCell
        let friend = friendList[indexPath.row] as! PFUser
        cell.nameLabel.text = friend["username"] as? String
        cell.userImageView!.image = UIImage(named: "placeHolder")

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        profileViewController.user = friendList[indexPath.row]
        self.navigationController?.pushViewController(profileViewController, animated: true)
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
