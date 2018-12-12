//
//  FriendsViewController.swift
//  ChatDemo
//
//  Created by Kawalpreet Kaur on 12/4/18.
//  Copyright © 2018 Kawalpreet Kaur. All rights reserved.
//

import UIKit
import SocketIO

class FriendsViewController: BaseViewController {

    @IBOutlet weak var tblForFriends: UITableView!
    
    var arrForFriends = Array<Dictionary<String,Any>>()
    var nickName: String?
    var sender: String?
    var socket: SocketIOClient?
    var messagesArray = Array<Any>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tblForFriends.tableFooterView = UIView()
        //connect the user to server with nickname
        if nickName == nil {
            askForNickname()
        }else{
            SocketIOManager.sharedInstance.connectToServerWithNickname(nickname: self.nickName ?? "", completionHandler: { (userList) -> Void in
                DispatchQueue.main.async { () -> Void in
                    if userList != nil {
                        self.arrForFriends = userList!
                        self.tblForFriends.reloadData()
                        self.tblForFriends.isHidden = false
                    }
                }
            })
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Function for alert to enter nickname
    func askForNickname() {
        let alertController = UIAlertController(title: "ChatDemo", message: "Please enter a nickname:", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField(configurationHandler: nil)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
            let textfield = alertController.textFields![0]
            if textfield.hasText {
                self.nickName = textfield.text
                SocketIOManager.sharedInstance.connectToServerWithNickname(nickname: self.nickName ?? "", completionHandler: { (userList) -> Void in
                    DispatchQueue.main.async { () -> Void in
                        if userList != nil {
                            self.arrForFriends = userList!
                            self.tblForFriends.reloadData()
                            self.tblForFriends.isHidden = false
                        }
                    }
                })
            }
            else {
                self.askForNickname()
            }
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
//MARK:------------------------UITableViewDelegate,UITableViewDataSource------------------------
extension FriendsViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrForFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friends", for: indexPath) as! FriendsTableViewCell
        cell.lblForNAme.text = arrForFriends[indexPath.row]["nickname"] as? String
        if arrForFriends[indexPath.row]["isConnected"] as? Int == 1{
            cell.lblForAvailability.text = "Online"
        }else{
            cell.lblForAvailability.text = "Offline"
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        controller.nickname = arrForFriends[indexPath.row]["nickname"] as? String
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
