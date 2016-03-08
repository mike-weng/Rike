//
//  AddFriendsViewController.swift
//  Rike
//
//  Created by Mike Weng on 2/21/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class AddFriendsViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var searchResult = [PFObject]()
    var searchQuery: PFQuery?
    

}

extension AddFriendsViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResult.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath)
        let user = searchResult[indexPath.row]
        
        cell.textLabel?.text = user["username"] as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        profileViewController.user = searchResult[indexPath.row]
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

extension AddFriendsViewController: UISearchBarDelegate {
    
    /* Each time the search text changes we want to cancel any current download and start a new one */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        /* Cancel the last task */
        if let query = searchQuery {
            query.cancel()
        }

        /* If the text is empty we are done */
        if searchText == "" {
            searchResult = [PFObject]()
            self.tableView.reloadData()
            return
        }
        
        let predicate = NSPredicate(format: "username BEGINSWITH '\(searchText)'")
        searchQuery = PFQuery(className: "_User", predicate: predicate)
        searchQuery?.limit = 10
        
        searchQuery?.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            self.searchQuery = nil
            if let result = result {
                self.searchResult = result
                self.tableView.reloadData()
            } else {
                Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
            }
        })

    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

