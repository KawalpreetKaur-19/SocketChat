//
//  SocketIOManager.swift
//  ChatDemo
//
//  Created by Kawalpreet Kaur on 12/4/18.
//  Copyright © 2018 Kawalpreet Kaur. All rights reserved.
//

import UIKit
import SocketIO

let manager = SocketManager(socketURL: URL(string: "http://172.10.228.203:3000")!, config: [.log(true), .compress])
let socket: SocketIOClient = manager.defaultSocket

class SocketIOManager: NSObject {
    //instance of the class
    static let sharedInstance = SocketIOManager()
    
    override init() {
        super.init()
    }
    //establish connection with server
    func establishConnection() {
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        socket.connect()
    }
    //close connection with server
    func closeConnection() {
        socket.disconnect()
    }
    // connect with server
    func connectToServerWithNickname(nickname: String, completionHandler: @escaping (_ userList: Array<Dictionary<String,Any>>?) -> Void) {
        socket.emit("connectUser", nickname)
        socket.on("SomeMessage") { ( dataArray, ack) -> Void in
            print(dataArray)
        }
        socket.on("userList") { ( dataArray, ack) -> Void in
            let data = dataArray[0] as! Array<Dictionary<String,Any>>
            print(dataArray)
            completionHandler(data)
        }
        //notifications
        listenForOtherMessages()
    }
    //send message
    func sendMessage(message: String, withNickname nickname: String) {
        socket.emit("chatMessage", nickname, message)
    }
    //get messages of the next user
    func getChatMessage(completionHandler: @escaping (_ messageInfo: Dictionary<String,Any>) -> Void) {
        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
            print(dataArray)
            let message = dataArray as! Array<String>
            var messageDictionary = Dictionary<String,Any>()
            messageDictionary["nickname"] = message[0]
            messageDictionary["message"] = message[1]
            messageDictionary["date"] = message[2]
            completionHandler(messageDictionary)
        }
    }
    //exit chat
    func exitChatWithNickname(nickname: String, completionHandler: () -> Void) {
        socket.emit("exitUser", nickname)
        completionHandler()
    }
    //Notifications of next user to be online, typing, offline
    private func listenForOtherMessages() {
        socket.on("userConnectUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userWasConnectedNotification"), object: dataArray[0] as! [String: AnyObject])
        }
        socket.on("userExitUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userWasDisconnectedNotification"), object: dataArray[0] as! String)
        }
        socket.on("userTypingUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"userTypingNotification"), object: dataArray[0] as! [String: AnyObject])
        }
    }
    // when user starts typing
    func sendStartTypingMessage(nickname: String) {
        socket.emit("startType", nickname)
    }
     // when user ends typing
    func sendStopTypingMessage(nickname: String) {
        socket.emit("stopType", nickname)
    }
}




