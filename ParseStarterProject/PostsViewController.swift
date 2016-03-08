//
//  PostsViewController.swift
//  Rike
//
//  Created by Mike Weng on 2/21/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class PostsViewController: UIViewController {
    
    var posts: [PFObject] = []
    var refresher: UIRefreshControl!

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.02, green: 0.02, blue: 0.53, alpha: 1.0)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        Convenience.configureActivityIndicator(self)
        loadPosts()
        configureRefresher()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPosts() {
        Convenience.startActivityIndicator()
        var postUsers = Convenience.friendList
        postUsers.append(Convenience.currentUser)
        let predicate = NSPredicate(format: "User IN %@", postUsers)
        let query = PFQuery(className: "Post", predicate: predicate)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if let result = result {
                self.posts = result
                self.tableView.reloadData()
            } else {
                Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
            }
            Convenience.stopActivityIndicator()
        }
    }
    
    func configureRefresher() {
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
    }
    func refresh() {
        loadPosts()
        self.tableView.reloadData()
        refresher.endRefreshing()
    }
}

extension PostsViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return posts.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! FeedCell
        let post = posts[indexPath.section]
        let imageFile = post["imageFile"] as! PFFile
        imageFile.getDataInBackgroundWithBlock({ (result, error) -> Void in
            if let imageData = result {
                cell.postImageView.image = UIImage(data: imageData)
            } else {
                Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
            }
        })
        cell.textView.text = post["caption"] as! String

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
//        profileViewController.user = searchResult[indexPath.row]
//        self.navigationController?.pushViewController(profileViewController, animated: true)
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell
        print(posts)
        let post = posts[section]
        headerCell.nameLabel.text = post["name"] as? String
        headerCell.usernameLabel.text = post["username"] as? String
        headerCell.backgroundColor = UIColor.whiteColor()

        return headerCell
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

