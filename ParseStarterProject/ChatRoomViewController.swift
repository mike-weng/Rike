//
//  ChatRoomViewController.swift
//  Rike
//
//  Created by Mike Weng on 2/27/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import PubNub

class ChatRoomViewController: UIViewController, PNObjectEventListener {
    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    var messages = [String]()
    var pubnub: PubNub? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.client
    }
    
    var user: PFUser!
    var channel: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTapRecognizer()
        pubnub?.addListener(self)
        pubnub?.subscribeToChannels([self.channel], withPresence: true)
        
        // Do any additional setup after loading the view.
        
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadMessages()
        self.enablePushNotification()
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configureTapRecognizer() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    func loadMessages() {
        self.pubnub?.historyForChannel(self.channel, start: nil, end: nil, limit: 40, reverse: false, includeTimeToken: false, withCompletion: { (result, status) -> Void in
            if status == nil {
                print(result?.data.messages)
                for message in result!.data.messages {
                    if let message = message as? String {
                        self.messages.append(message)
                    } else if let dict = message as? NSDictionary {
                        if let pnOther = dict["pn_other"] as? String {
                            self.messages.append(pnOther)
                        }
                    }
                }
                
                
                self.tableView.reloadData()
                // Handle downloaded history using:
                //   result.data.start - oldest message time stamp in response
                //   result.data.end - newest message time stamp in response
                //   result.data.messages - list of messages
            }
            else {
                
                // Handle message history download error. Check 'category' property
                // to find out possible reason because of which request did fail.
                // Review 'errorData' property (which has PNErrorData data type) of status
                // object to get additional information about issue.
                //
                // Request can be resent using: status.retry()
            }
        })
    }
    
    func enablePushNotification() {
        let deviceToken = NSUserDefaults.standardUserDefaults().objectForKey("DeviceToken") as! NSData
        self.pubnub!.addPushNotificationsOnChannels([self.channel],
            withDevicePushToken: deviceToken,
            andCompletion: { (status) -> Void in
                
                if !status.error {
                    print("pushEnabled")
                    // Handle successful push notification enabling on passed channels.
                }
                else {
                    
                    // Handle modification error. Check 'category' property
                    // to find out possible reason because of which request did fail.
                    // Review 'errorData' property (which has PNErrorData data type) of status
                    // object to get additional information about issue.
                    //
                    // Request can be resent using: status.retry()
                }
        })
    }
    
    @IBAction func sendButtonTouchUp(sender: AnyObject) {
        let alertMsg = "message from " + (Convenience.currentUser["name"] as! String)
        let payload = ["aps" : ["alert" : alertMsg]]
        self.pubnub?.publish(messageTextField.text!, toChannel: self.channel, mobilePushPayload: payload, storeInHistory: true, compressed: false, withCompletion: { (status) -> Void in
            if !status.error {
                // Message successfully published to specified channel.
                
            }
            else{
                
                // Handle message publish error. Check 'category' property
                // to find out possible reason because of which request did fail.
                // Review 'errorData' property (which has PNErrorData data type) of status
                // object to get additional information about issue.
                //
                // Request can be resent using: status.retry()
                let errorMsg = status.error.description
                Convenience.showAlert(self, title: "Sent Error", message: errorMsg)
                
            }

        })
        self.messageTextField.text = ""
    }
    func client(client: PubNub, didReceiveMessage message: PNMessageResult) {
        
        // Handle new message stored in message.data.message
        if message.data.actualChannel != nil {
            // Message has been received on channel group stored in
            // message.data.subscribedChannel

        }
        else {
            
            // Message has been received on channel stored in
            // message.data.subscribedChannel
        }
        let data = message.data.message as! NSDictionary
        messages.append(data["pn_other"] as! String)
        self.tableView.reloadData()
        print("Received message: \(message.data.message) on channel " +
            "\((message.data.actualChannel ?? message.data.subscribedChannel)!) at " +
            "\(message.data.timetoken)")
    }

    
}

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messages.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath)
        cell.textLabel?.text = messages[indexPath.row]

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        let chatRoomViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChatRoomViewController") as! ChatRoomViewController
//        
//        let chat = chats[indexPath.row]
//        var user = chat["ToUser"] as! PFUser
//        if user == Convenience.currentUser {
//            user = chat["FromUser"] as! PFUser
//        }
//        
//        chatRoomViewController.user = user
//        self.navigationController?.pushViewController(chatRoomViewController, animated: true)
        
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


extension ChatRoomViewController {
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) - (self.tabBarController?.tabBar.frame.height)!
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
}

