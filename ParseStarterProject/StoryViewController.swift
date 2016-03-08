//
//  StoryViewController.swift
//  Rike
//
//  Created by Mike Weng on 2/24/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class StoryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var myStoryButton: UIButton!
    @IBOutlet weak var newStoryButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var refresher: UIRefreshControl!
    var panGesture: UIPanGestureRecognizer!
    var longPressGesture: UILongPressGestureRecognizer!
    var stories: NSMutableArray!
    var myStories = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.02, green: 0.02, blue: 0.53, alpha: 1.0)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        configureRefresher()
        Convenience.configureActivityIndicator(self)
        Convenience.startActivityIndicator()
        loadStories()
        configurePanGesture()

        // Do any additional setup after loading the view.
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
    
    @IBAction func addStoryTouchUp(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(pickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.dismissViewControllerAnimated(true, completion: nil)
            let storyPreviewViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StoryPreviewViewController") as! StoryPreviewViewController
            storyPreviewViewController.image = image
            
            self.navigationController?.pushViewController(storyPreviewViewController, animated: true)
        }
        
    }
    @IBAction func myStoriesTouchUp(sender: AnyObject) {
        Convenience.startActivityIndicator()
        imageView.hidden = true
        tableView.hidden = false
        loadMyStories()
        configureLongPressGesture()
    }
    
    @IBAction func newStoriesTouchUp(sender: AnyObject) {
        Convenience.startActivityIndicator()
        loadStories()
        configurePanGesture()
    }
    
    func loadMyStories() {
        let relation = Convenience.currentUser.relationForKey("Story")
        let query = relation.query()
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if let result = result {
                self.myStories = result
                self.tableView.reloadData()
            }  else {
                Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
            }
            Convenience.stopActivityIndicator()
        }
    }
    
    func loadStories() {
        let query = PFQuery(className: "Story")
        query.whereKey("ToUsers", equalTo: Convenience.currentUser)
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if let result = result {
                self.stories = NSMutableArray(array: result)
                self.loadStoryImage()
            }  else {
                Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
            }
        }
    }
    
    func loadStoryImage() {
        if let story = stories.firstObject {
            let imageFile = story["imageFile"] as! PFFile
            imageFile.getDataInBackgroundWithBlock({ (result, error) -> Void in
                if let imageData = result {
                    self.imageView.image = UIImage(data: imageData)
                    self.imageView.hidden = false
                    self.tableView.hidden = true
                } else {
                    Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
                }
                Convenience.stopActivityIndicator()
            })
        } else {
            imageView.hidden = true
            imageView.removeGestureRecognizer(panGesture)
        }
        
    }
    
    func configurePanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: "handleDrag:")
        imageView.addGestureRecognizer(panGesture)
    }
    
    func handleDrag(gesture: UIPanGestureRecognizer) {
        let image = gesture.view!
        let translation = gesture.translationInView(self.view)
        let screenX = self.view.bounds.width
        let screenY = self.view.bounds.height
        
        image.center = CGPoint(x: screenX / 2 + translation.x, y: screenY / 2 + translation.y)
        
        let xFromCenter = image.center.x - screenX / 2
        let yFromCenter = image.center.y - screenY / 2

        var scale = min(100 / abs(xFromCenter), 1)
        
        if abs(xFromCenter) < abs(yFromCenter) {
            scale = min(100 / abs(yFromCenter), 1)
        }
        
        var rotation = CGAffineTransformMakeRotation(xFromCenter / 200)

        var stretch = CGAffineTransformScale(rotation, scale, scale)
        image.transform = stretch

        if gesture.state == UIGestureRecognizerState.Ended {
            let story = stories.firstObject
            var relation: PFRelation

            if image.center.x < 150 {
                print("dislike")
                relation = story!.relationForKey("UsersDisliked")
                relation.addObject(Convenience.currentUser)
            } else if image.center.x > screenX - 150 {
                print("like")
                relation = story!.relationForKey("UsersLiked")
                relation.addObject(Convenience.currentUser)
            } else if image.center.y > screenY - 100 {
                print("no comment")
                relation = story!.relationForKey("UsersNoComment")
                relation.addObject(Convenience.currentUser)
            } else {
                rotation = CGAffineTransformMakeRotation(0)
                stretch = CGAffineTransformScale(rotation, 1, 1)
                image.transform = stretch
                image.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
                return
            }
            
            story!.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    self.stories.removeObject(story!)
                    self.loadStoryImage()
                    
                    print("success")
                } else {
                    Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
                }
                rotation = CGAffineTransformMakeRotation(0)
                stretch = CGAffineTransformScale(rotation, 1, 1)
                image.transform = stretch
                image.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            })

        }
        
    }
    
    func configureLongPressGesture() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
        longPressGesture.minimumPressDuration = 0.5
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongPress(gesture: UILongPressGestureRecognizer) {
        print("press")
        if gesture.state == UIGestureRecognizerState.Began {
            let point = gesture.locationInView(tableView)
            let indexPath = tableView.indexPathForRowAtPoint(point)
            if indexPath != nil {
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as! StoryCell
                tableView.hidden = true
                imageView.hidden = false
                imageView.image = cell.storyImageView.image
            }
        }
        
        if gesture.state == UIGestureRecognizerState.Ended {
            tableView.hidden = false
            imageView.hidden = true
        }
    }
    
    func refresh() {
        loadMyStories()
        refresher.endRefreshing()
    }
    
    func configureRefresher() {
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
    }

}

extension StoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myStories.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StoryCell", forIndexPath: indexPath) as! StoryCell
        let story = myStories[indexPath.row]
        let imageFile = story["imageFile"] as! PFFile
        imageFile.getDataInBackgroundWithBlock({ (result, error) -> Void in
            if let imageData = result {
                cell.storyImageView.image = UIImage(data: imageData)
            } else {
                Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
            }
        })
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, MMM dd, yyyy, HH:mm:ss"
        let date = story.createdAt
        cell.dateLabel.text = dateFormatter.stringFromDate(date!)

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let storyResponseViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StoryResponseViewController") as! StoryResponseViewController
        storyResponseViewController.story = myStories[indexPath.row]
        self.navigationController?.pushViewController(storyResponseViewController, animated: true)
        tableView
        
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

