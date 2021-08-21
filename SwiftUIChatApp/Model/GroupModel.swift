//
//  GroupModel.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 16/07/21.
//

import Foundation
import SwiftUI

let kTitle = "title"
let kGroupID = "groupID"
let kAdmin = "admin"

class GroupModel: NSObject,Identifiable {
    
    var groupID:String
    var title: String
    var admin:String
    var createdTimeStamp:Double
    var userIds:[String]
    var lastMessage:MessageModel
    var lastMessageString:String = ""
    var isSelected:Bool = false
    var dateString = ""
    var avtarColor = Color(red: .random(in: 0.3...0.7), green: .random(in: 0.2...0.7), blue: .random(in: 0.1...0.7))
    
    // init
    init(dict:[String:Any]) {
        
        self.groupID = dict[kGroupID] as? String ?? ""
        self.title = dict[kTitle] as? String ?? ""
        self.createdTimeStamp = dict[kCreatedTimeStamp] as? Double ?? 0
        self.userIds = dict[kUserIds] as? [String] ?? [""]
        self.admin = dict[kAdmin] as? String ?? ""
        let dataDict = dict[kLastMessage] as? [String:Any] ?? [:]
        self.lastMessage = MessageModel(dict: dataDict)
        
    }
    
    // init empty model
    init(groupID:String = "",title:String = "",createdTimeStamps:Double = 0,userIds:[String] = [""],adminString:String = "",lastMesageData: MessageModel = MessageModel()) {
        
        self.groupID = groupID
        self.title = title
        self.createdTimeStamp = createdTimeStamps
        self.userIds = userIds
        self.admin = adminString
        self.lastMessage = lastMesageData
    }
    
    
}
