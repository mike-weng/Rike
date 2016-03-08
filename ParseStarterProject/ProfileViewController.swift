//
//  ProfileViewController.swift
//  Rike
//
//  Created by Mike Weng on 2/21/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var numRikesLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    
    var user: PFObject!
    var friendshipStatus = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Convenience.configureActivityIndicator(self)
        configureProfile()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureProfile() {
        nameLabel.text = user["name"] as? String
        usernameLabel.text = user["username"] as? String
        if let profilePicture = user["profilePicture"] {
            let imageFile = profilePicture as! PFFile
            imageFile.getDataInBackgroundWithBlock { (result, error) -> Void in
                if let imageData = result {
                    self.imageView.image = UIImage(data: imageData)
                } else {
                    Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
                }
            }
        }
        updateFriendshipStatus()
    }
    
    func updateFriendshipStatus() {
        var relation = Convenience.currentUser.relationForKey("friends")
        var query = relation.query()
        query.whereKey("objectId", equalTo: user.objectId!)
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if let result = result {
                if result != [] {
                    self.friendshipStatus++
                }
            } else {
                Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
            }
            relation = self.user.relationForKey("friends")
            query = relation.query()
            query.whereKey("objectId", equalTo: Convenience.currentUser.objectId!)
            query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
                if let result = result {
                    if result != [] {
                        if self.friendshipStatus != -1 {
                            self.friendshipStatus++
                        }
                    }
                } else {
                    Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
                }
                self.updateAddFriendButoon()
            })

        }
    }
    
    func updateAddFriendButoon() {
        switch self.friendshipStatus {
        case -1:
            self.addFriendButton.setTitle("Add as Friend", forState: .Normal)
        case 0:
            self.addFriendButton.enabled = false
            self.addFriendButton.setTitle("Waiting for response..", forState: .Normal)
        case 1:
            self.addFriendButton.setTitle("Let's Chat", forState: .Normal)
        default:
            return
        }
    }
    
    
    
    @IBAction func addFriendTouchUp(sender: AnyObject) {
        Convenience.startActivityIndicator()
        let relation = Convenience.currentUser.relationForKey("friends")
        relation.addObject(user)
        Convenience.currentUser.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                self.configureProfile()
            } else {
                Convenience.showAlert(self, title: "Error", message: error!.userInfo["error"] as! String)
            }
            Convenience.stopActivityIndicator()
        })
        
        
    }

}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("BuzzCell", forIndexPath: indexPath) as UICollectionViewCell
        cell.backgroundColor = UIColor.grayColor()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("cell")
    }

}