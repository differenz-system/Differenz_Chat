//
//  ChatModel.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 12/07/21.
//

import Foundation


//MARK: - Global Variable
let kChatID = "chatID"
let kSenderID = "senderID"
let kReceiverID = "receiverID"
let kMessage = "message"
let kShareID = "shareID"
let kMessageType = "messageType" // 1 for text and 2 for image
let kimageURL = "imageURL"

class ChatModel: NSObject {
    
    var chatID: String
    var senderID: String
    var receiverID: String
    var message: String
    var createdTimeStamp: Double
    var shareID: String
    
    // init 
    init( dict: [String:Any]) {
        self.chatID = dict[kChatID] as? String ?? ""
        self.senderID = dict[kSenderID] as? String ?? ""
        self.receiverID = dict[kReceiverID] as? String ?? ""
        self.message = dict[kMessage] as? String ?? ""
        self.createdTimeStamp = dict[kCreatedTimeStamp] as? Double ?? 0
        self.shareID = dict[kShareID] as? String ?? ""
    }

}

