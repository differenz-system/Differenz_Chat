//
//  MessageModel.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 14/07/21.
//

import Foundation

let kBody = "body"
let kCreatedAt = "createdAt"
let kUserId = "userId"
let kDocumentId = "documentId"
let kUserName = "userName"

class MessageModel: NSObject, Encodable {
    
    var body:String
    var createdAt:Double
    var userId:String
    var documentId:String
    var userName:String = ""
    var messageType: Int
    var imageURL: String
    
    // init  with dictnoary
    init(dict:[String:Any]) {
        
        self.body = dict[kBody] as? String ?? ""
        self.createdAt = dict[kCreatedAt] as? Double ?? 0
        self.userId = dict[kUserId] as? String ?? ""
        self.documentId = dict[kDocumentId] as? String ?? ""
        self.userName = dict[kUserName] as? String ?? ""
        self.messageType = dict[kMessageType] as? Int ?? 1
        self.imageURL = dict[kimageURL] as? String ?? ""
        
    }
    
    // init empty model
    init(textMessage bodyString:String = "",createdAt createdAtStrint:Double = 0,userId userIdString:String = "",documentId documentIdString:String = "",userName userNameString:String = "",messageType messageTypeString:Int = 0,imageURL imageurlString:String = "") {
        
        self.body = bodyString
        self.createdAt = createdAtStrint
        self.userId = userIdString
        self.documentId = documentIdString
        self.userName = userNameString
        self.messageType = messageTypeString
        self.imageURL = imageurlString
        
    }
    
    // init
    init(body bodyString:String,createdAt createdAtStrint:Double,userId userIdString:String,documentId documentIdString:String,userName userNameString:String,messageType messageTypeString:Int,imageURL imageurlString:String) {
        
        
        self.body = bodyString
        self.createdAt = createdAtStrint
        self.userId = userIdString
        self.documentId = documentIdString
        self.userName = userNameString
        self.messageType = messageTypeString
        self.imageURL = imageurlString
        
    }
    
    
    
    
}
