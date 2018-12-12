//
//  ChatViewController.swift
//  ChatDemo
//
//  Created by Kawalpreet Kaur on 12/4/18.
//  Copyright © 2018 Kawalpreet Kaur. All rights reserved.
//

import UIKit

class ChatViewController: BaseViewController {

    @IBOutlet weak var tblForChat: UITableView!
    @IBOutlet weak var btnToSendMessage: UIButton!
    @IBOutlet weak var txtViewForMessage: UITextView!
    @IBOutlet weak var lblForTyping: UILabel!
    
    var nickname:String?
    var arrForMessages = Array<Dictionary<String,Any>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = self.nickname
        tblForChat.tableFooterView = UIView()
        //observer for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectedUserUpdateNotification), name: NSNotification.Name(rawValue: "userWasConnectedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDisconnectedUserUpdateNotification), name: NSNotification.Name(rawValue: "userWasDisconnectedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserTypingNotification), name: NSNotification.Name(rawValue:"userTypingNotification"), object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        SocketIOManager.sharedInstance.getChatMessage { (messageInfo) -> Void in
            DispatchQueue.main.async {
                self.arrForMessages.append(messageInfo)
                self.tblForChat.reloadData()
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:-------------------@IBAction-------------------
    @IBAction func actionToSendMessage(_ sender: Any) {
        if txtViewForMessage.hasText{
            SocketIOManager.sharedInstance.sendMessage(message: txtViewForMessage.text ?? "", withNickname: nickname ?? "")
            txtViewForMessage.text = ""
            txtViewForMessage.resignFirstResponder()
        }
    }
    //other user gets connected
    @objc func handleConnectedUserUpdateNotification(notification: NSNotification) {
        let connectedUserInfo = notification.object as! [String: AnyObject]
        let connectedUserNickname = connectedUserInfo["nickname"] as? String

    }
    //other user gets disconnected
    @objc func handleDisconnectedUserUpdateNotification(notification: NSNotification) {
        let disconnectedUserNickname = notification.object as! String
    }
    //other user is typing
    @objc func handleUserTypingNotification(notification: NSNotification) {
        if let typingUsersDictionary = notification.object as? [String: AnyObject] {
            self.lblForTyping.isHidden = false
            var names = ""
            var totalTypingUsers = 0
            for (typingUser, _) in typingUsersDictionary {
                if typingUser != nickname {
                    names = (names == "") ? typingUser : "\(names), \(typingUser)"
                    totalTypingUsers += 1
                }
            }
            if totalTypingUsers > 0 {
                let verb = (totalTypingUsers == 1) ? "is" : "are"
            }
            else {
                self.lblForTyping.isHidden = true
            }
        }
    }
    //function to dismiss keyboard
    func dismissKeyboard() {
        if txtViewForMessage.isFirstResponder {
            txtViewForMessage.resignFirstResponder()
            SocketIOManager.sharedInstance.sendStopTypingMessage(nickname: nickname ?? "")
        }
    }
}
//MARK:-------------------UITableViewDataSource and UITableViewDelegate-------------------
extension ChatViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrForMessages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register( UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "chat")
        let cell = tableView.dequeueReusableCell(withIdentifier: "chat", for: indexPath) as! UserTableViewCell
        let currentChatMessage = arrForMessages[indexPath.row]
        let senderNickname = currentChatMessage["nickname"] as! String
        let message = currentChatMessage["message"] as! String
        let messageDate = currentChatMessage["date"] as! String
        if senderNickname == nickname {
            cell.lblForMessage.textAlignment = NSTextAlignment.right
            cell.lblForTime.textAlignment = NSTextAlignment.right
        }
        cell.lblForMessage.text = message
        cell.lblForTime.text = messageDate
        cell.lblForMessage.textColor = UIColor.darkGray
        return cell
    }
}
//MARK:-------------------UITextViewDelegate-------------------
extension ChatViewController:UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        SocketIOManager.sharedInstance.sendStartTypingMessage(nickname: nickname ?? "")
        return true
    }
   
}
