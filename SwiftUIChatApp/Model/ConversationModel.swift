//
//  ConversationModel.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 14/07/21.
//

import Foundation


let kConversationID = "conversationID"
let kCreatedTimeStamp = "createdTimeStamp"
let kUserIds = "userIds"
let kLastMessage = "lastMessage"


class ConversationModel: NSObject {
    
    var conversationID:String
    var createdTimeStamp:Double
    var userIds:[String]
    var lastMessage:MessageModel
    
    // init 
    init(dict: [String:Any]) {
        
        self.conversationID = dict[kConversationID] as? String ?? ""
        self.createdTimeStamp = dict[kCreatedTimeStamp] as? Double ?? 0
        self.userIds = dict[kUserIds] as? [String] ?? [""]
        let dataDict = dict[kLastMessage] as? [String:Any] ?? [:]
        self.lastMessage = MessageModel(dict: dataDict)
    }
    
}
