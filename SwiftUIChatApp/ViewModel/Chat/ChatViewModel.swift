//
//  ChatViewModel.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 12/07/21.
//

import Foundation
import SwiftUI

//MARK: - BubblePosition
enum BubblePosition {
    case left
    case right
}




//MARK: - ChatViewModel
class ChatViewModel: ObservableObject {
    
    @Published var openFullCamera = false
    @Published var openSheet = false
    @Published var showAlert = false
    @Published var showSheetTypes = ""
    @Published var showAlertTypes = ""
    @Published var adminName = ""
    @Published var messageTextField = ""
    @Published var arrayOfPositions : [BubblePosition] = []
    @Published var arrOfTimeStamp: [Int64] = []
    @Published var position = BubblePosition.right
    @Published var arrMessageData: [MessageModel] = []
    @Published var navigation:String? = nil
    @Published var arrChatData: [ChatModel] = []
    @Published var iaDataAdded = false
    private var selectedConversationModel:ConversationModel?
    var storageVM = firebaseStorageViewModel()
    
    // open image
    @Published var imageURL:String = ""
    @Published var openImage = false
    @Published var disableTextField = false
    
    // forword message
    @Published var selectedMessage = MessageModel()
    @Published var chatUserID = String()
    @Published var isFromGroup = false
    
    
    //    private var documentArray1
    private var db = Firestore.firestore()
    
    init() {
        UIScrollView.appearance().bounces = false
    }
    
}


//MARK: - Helper methods
extension ChatViewModel {
    
    
    ///  show image in full screen
    /// - Parameter imageUrl: imageUrl used to show image
    func openImage(imageUrl: String) {
        self.openImage = true
        self.imageURL = imageUrl
    }
    
    /// show group's existing users
    func moveToGruopList() {
        self.navigation = IdentifiableKeys.NavigationTags.knavToGroupChat
    }
    
}


//MARK: - one to one chat

extension ChatViewModel {
    
    /// Path to conversation message
    /// - Parameter conversationId: conversationId description
    /// - Returns: message document path
    func getConversationDocumentReference(conversationId: String) -> DocumentReference {
        
        db.collection(Constant.FireBase.conversationCollection)
            .document(conversationId)
    }
    
    
    
    
    /// create conversation ID
    /// - Parameters:
    ///   - senderID: sender ID
    ///   - receriverID: receiver ID
    /// - Returns: conversationID
    func getConversationID(senderID: String,receriverID: String) -> String {
        
        var conversationID = ""
        
        if senderID > receriverID {
            conversationID = "\(senderID)_\(receriverID)"
        } else {
            conversationID = "\(receriverID)_\(senderID)"
        }
        
        return conversationID
        
    }
    
    /// fetch message form conversation collection
    /// - Parameters:
    ///   - senderID: sender ID
    ///   - receriverID: receiver ID
    ///   - completion: return success or failure
    func fetchMessagesFormCollection(senderID: String,receriverID: String, completion: @escaping (Bool) -> Void) {
        
        let conversationID = getConversationID(senderID: senderID, receriverID: receriverID)
        
        getConversationDocumentReference(conversationId: conversationID).addSnapshotListener { (DocumentSnapshot, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "error occur while get documnet")
                completion(false)
            } else {
                
                guard let document = DocumentSnapshot else {
                    return
                }
                
                if document.exists {
                    
                    guard let documnetData = document.data() else {
                        completion(false)
                        return
                    }
                    
                    self.selectedConversationModel = ConversationModel(dict: documnetData)
                    
                    self.getConversationDocumentReference(conversationId: conversationID).collection(Constant.FireBase.messagesCollection).order(by: kCreatedAt).addSnapshotListener { (QuerySnapshot, error) in
                        
                        if error != nil {
                            print(error?.localizedDescription ?? "error occur while get documnet")
                            completion(false)
                        } else {
                            
                            self.arrayOfPositions.removeAll()
                            self.arrMessageData.removeAll()
                            self.arrOfTimeStamp.removeAll()
                            
                            guard let documents = QuerySnapshot?.documents else {
                                print("No documents")
                                return
                            }
                            
                            self.arrMessageData = documents.map({ (QueryDocumentSnapshot) -> MessageModel in
                                let data = QueryDocumentSnapshot.data()
                                return MessageModel(dict: data)
                            })
                            
                            for chat in self.arrMessageData {
                                let timeStamp = Int64(chat.createdAt)
                                self.arrOfTimeStamp.append(timeStamp)
                                if chat.userId == UserModel.getCurrentUserID() {
                                    self.arrayOfPositions.append(BubblePosition.right)
                                } else {
                                    self.arrayOfPositions.append(BubblePosition.left)
                                }
                                
                            }
                            
                            
                        }
                        
                        
                        
                    }
                    
                    completion(true)
                    
                } else {
                    print("document not exist ")
                    completion(false)
                }
                
            }
            
            
        }
        
    }
    
    
    /// add message into conversation collection
    /// - Parameters:
    ///   - senderID: senderID
    ///   - receriverID: receiverID
    ///   - message: send message
    ///   - messageType: which type of message   // 1 -  text , 2 - image,  3 - image and text
    ///   - imageurl: image url
    ///   - timeStamp: date timestamp
    ///   - completion: return message dictionary
    func addMessageToCollection(senderID: String,receriverID: String,message: String,messageType:Int,imageurl:String, timeStamp: Double, completion: @escaping ([String:Any]) -> Void) {
        
        var conversationID = ""
        
        if senderID > receriverID {
            conversationID = "\(senderID)_\(receriverID)"
        } else {
            conversationID = "\(receriverID)_\(senderID)"
        }
        
        //2: add data into message collection
        let DocumentID = getConversationDocumentReference(conversationId: conversationID).collection(Constant.FireBase.messagesCollection).document().documentID
        let messageData:[String:Any] = [kBody:message,kCreatedAt:timeStamp,kUserId:senderID,kDocumentId:DocumentID,kMessageType:messageType,kimageURL:imageurl]
        
        //1: add data into coversation collection
        db.collection(Constant.FireBase.conversationCollection).document(conversationID).getDocument { (DocumentSnapshot, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "error occur in fire part 1")
                return
            } else {
                
                guard let document = DocumentSnapshot else {
                    return
                }
                
                if document.exists {
                    print("document is alraedy exist")
                    let conversationData:[String:Any] = [kConversationID:conversationID,kCreatedTimeStamp:timeStamp,kUserIds:[senderID,receriverID],kLastMessage:messageData]
                    self.db.collection(Constant.FireBase.conversationCollection).document(conversationID).setData(conversationData,merge: true)
                } else {
                    let conversationData:[String:Any] = [kConversationID:conversationID,kCreatedTimeStamp:timeStamp,kUserIds:[senderID,receriverID],kLastMessage:messageData]
                    self.db.collection(Constant.FireBase.conversationCollection).document(conversationID).setData(conversationData)
                }
                
            }
            
        }
        
        getConversationDocumentReference(conversationId: conversationID).collection(Constant.FireBase.messagesCollection).document(DocumentID).setData(messageData)
        completion(messageData)
        
        
    }
    
    
    /// delete message form conversation collection .
    ///  also delete image form firebase store image if message type  = 2/3
    /// - Parameters:
    ///   - senderID: senderID
    ///   - receriverID: receriverID
    ///   - messageID: message id of delete particular data
    ///   - messageType: which type of message   // 1 -  text , 2 - image,  3 - image and text
    ///   - imageFileURL: image url
    ///   - userModel: userModel
    func deleteMessage(senderID: String,receriverID: String,messageID: String,messageType: Int,imageFileURL: String,userModel:UserModel) {
        
        let conversationID = self.getConversationID(senderID: senderID, receriverID: receriverID)
        
        if messageType == 1 {
            
            self.getConversationDocumentReference(conversationId: conversationID).collection(Constant.FireBase.messagesCollection).document(messageID).delete { (error) in
                
                if error != nil {
                    print(error?.localizedDescription ?? "error occur while deleting message")
                    
                    
                } else {
                    
                    guard let coversation = self.selectedConversationModel else {
                        return
                    }
                    
                    
                    if messageID == coversation.lastMessage.documentId {
                        
                        self.db.collection(Constant.FireBase.conversationCollection).document(conversationID).updateData([kLastMessage: FieldValue.delete()]) { (error) in
                            
                            if error != nil {
                                
                                print(error?.localizedDescription as Any)
                                
                            } else {
                                print("successfull delete last message")
                                
                                self.addLastMessageInConverstaion(conversationID: conversationID)
                                
                            }
                            
                            
                        }
                        
                    }
                    
                }
                
            }
            
        } else {
            
            storageVM.deleteFile(fileURL: imageFileURL) { (sucess) in
                
                if sucess {
                    
                    self.getConversationDocumentReference(conversationId: conversationID).collection(Constant.FireBase.messagesCollection).document(messageID).delete { (error) in
                        
                        if error != nil {
                            print(error?.localizedDescription ?? "error occur while deleting message")
                            
                        } else {
                            
                            
                            guard let coversation = self.selectedConversationModel else {
                                return
                            }
                            
                            if messageID == coversation.lastMessage.documentId {
                                
                                self.addLastMessageInConverstaion(conversationID: conversationID)
                                
                            }
                            
                            
                        }
                        
                    }
                    
                } else {
                    print(sucess)
                }
                
            }
            
        }
        
    }
    
    
    /// add last message in conversation collection
    /// - Parameter conversationID: converstionID of users
    func addLastMessageInConverstaion(conversationID: String) {
        
        self.getConversationDocumentReference(conversationId: conversationID).collection(Constant.FireBase.messagesCollection).order(by: kCreatedAt,descending: true).addSnapshotListener { (QuerySnapshot, error) in
            
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            } else {
                
                guard let documents = QuerySnapshot?.documents else {
                    return
                }
                
                var arrMessage = [MessageModel]()
                
                arrMessage = documents.map({ (QueryDocumentSnapshot) -> MessageModel in
                    
                    let data = QueryDocumentSnapshot.data()
                    return MessageModel(dict: data)
                    
                })
                
                if arrMessage.isEmpty {
                    return
                } else {
                    
                    guard let lastMessage = arrMessage.first else {
                        return
                    }
                    
                    let messageData:[String:Any] = [kBody:lastMessage.body,kCreatedAt:lastMessage.createdAt,kDocumentId:lastMessage.documentId,kMessageType:lastMessage.messageType,kimageURL:lastMessage.imageURL]
                    
                    let conversationDATA:[String:Any] = [kConversationID:self.selectedConversationModel?.conversationID ?? "",kCreatedTimeStamp:self.selectedConversationModel?.createdTimeStamp ?? 0,kUserIds:self.selectedConversationModel?.userIds ?? [""],kLastMessage:messageData]
                    
                    self.db.collection(Constant.FireBase.conversationCollection).document(conversationID).setData(conversationDATA, merge: true)
                    
                    print("successfull added new last message")
                    
                }
                
            }
            
            
        }
        
    }
    
}


//MARK: - Group chat
extension ChatViewModel {
    
    /// get name of admin form user collection
    /// - Parameter AdminID: asmin id form group collection
    func getAdminName(AdminID: String)  {
        
        self.db.collection(Constant.FireBase.userCollection).document(AdminID).getDocument { (DocumentSnapshot, error) in
            
            
            if error != nil {
                
                print(error?.localizedDescription ?? "error occur while fetching admin name")
                return
                
            } else {
                
                guard let document = DocumentSnapshot else {
                    return
                }
                
                
                if document.exists {
                    
                    guard let adminData = document.data() else {
                        return
                    }
                    
                    let firstname = adminData[kFirstName] as? String ?? ""
                    let lastName = adminData[klastName] as? String ?? ""
                    
                    self.adminName = "\(firstname) \(lastName)"
                    
                    
                    
                } else {
                    
                }
                
                
                
            }
        }
    }
    
    
    /// document path of groupCollection
    /// - Parameter GroupID: geoupID
    /// - Returns: return total path of groupID
    func getGroupDocumentReference(GroupID: String) -> DocumentReference {
        db.collection(Constant.FireBase.groupCollection).document(GroupID)
    }
    
    
    /// fetch message form message collection of group collection
    /// - Parameters:
    ///   - GroupID: groupId of particular group
    ///   - completion: return success or failure
    func fetchMessagesForGroupCollcetion(GroupID: String,completion: @escaping (Bool) -> Void) {
        
        
        self.getGroupDocumentReference(GroupID: GroupID).collection(Constant.FireBase.messagesCollection).order(by: kCreatedAt).addSnapshotListener { (QuerySnapshot, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "error occur while get documnet")
                completion(false)
            } else {
                
                self.arrayOfPositions.removeAll()
                self.arrMessageData.removeAll()
                self.arrOfTimeStamp.removeAll()
                
                guard let documents = QuerySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                self.arrMessageData = documents.map({ (QueryDocumentSnapshot) -> MessageModel in
                    let data = QueryDocumentSnapshot.data()
                    return MessageModel(dict: data)
                })
                
                for chat in self.arrMessageData {
                    
                    let timeStamp = Int64(chat.createdAt)
                    self.arrOfTimeStamp.append(timeStamp)
                    if chat.userId == UserModel.getCurrentUserID() {
                        self.arrayOfPositions.append(BubblePosition.right)
                    } else {
                        self.arrayOfPositions.append(BubblePosition.left)
                    }
                    
                }
                
            }
            
            completion(true)
        }
        
    }
    
    
    /// send message in group
    /// add message in group collection
    /// - Parameters:
    ///   - GroupID: groupId of particluar group
    ///   - message: send message
    ///   - messageType: message type of message. 1- text, 2- image ,3- image and text
    ///   - imageurl: image url
    ///   - groupModel: group data model
    ///   - completion: return message Model data
    func addMessageInGroupCollcetion(GroupID: String,message: String,messageType:Int,imageurl:String,groupModel: GroupModel, completion: @escaping ([String:Any]) -> Void) {
        
        guard let currentUser = UserModel.getCurrentUserFromDefault() else {
            return
        }
        
        let documentID = getGroupDocumentReference(GroupID: GroupID).collection(Constant.FireBase.messagesCollection).document().documentID
        
        let messageData:[String:Any] = [kBody:message,kCreatedAt: Date().UTCTimeStamp,kUserId:UserModel.getCurrentUserID(),kUserName:"\(currentUser.firstName) \(currentUser.lastName)",kDocumentId:documentID,kMessageType:messageType,kimageURL:imageurl]
        self.getGroupDocumentReference(GroupID: GroupID).collection(Constant.FireBase.messagesCollection).document(documentID).setData(messageData)
        
        let groupData:[String:Any] = [kGroupID: groupModel.groupID,kTitle: groupModel.title,kAdmin: groupModel.admin,kCreatedTimeStamp:groupModel.createdTimeStamp,kUserIds:groupModel.userIds,kLastMessage:messageData]
        
        self.db.collection(Constant.FireBase.groupCollection).document(GroupID).setData(groupData, merge: true)
        
        completion(messageData)
        
    }
    
    /// delete message form group collection
    /// - Parameters:
    ///   - groupID: groupid of perticular group
    ///   - messageID: message id of particluar message
    ///   - messageType: message type of message. 1- text, 2- image ,3- image and text
    ///   - imageFileURL: image url
    ///   - groupModel: group data model
    func deleteMessageFromGroupCollcetion(groupID: String, messageID: String,messageType: Int,imageFileURL: String,groupModel:GroupModel) {
        
        if messageType == 1 {
            
            self.getGroupDocumentReference(GroupID: groupID).collection(Constant.FireBase.messagesCollection).document(messageID).delete { (error) in
                if error != nil {
                    print(error?.localizedDescription ?? "error occur while deleting message")
                    
                } else {
                    
                    if messageID == groupModel.lastMessage.documentId {
                        
                        self.db.collection(Constant.FireBase.groupCollection).document(groupModel.groupID).updateData([
                            kLastMessage: FieldValue.delete(),
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                                self.addLastMessageInGroupCollcetion(groupModel: groupModel)
                            }
                        }
                        
                    }
                    
                }
            }
            
            
        } else {
            
            storageVM.deleteFile(fileURL: imageFileURL) { (success) in
                
                if success {
                    
                    self.getGroupDocumentReference(GroupID: groupID).collection(Constant.FireBase.messagesCollection).document(messageID).delete { (error) in
                        if error != nil {
                            print(error?.localizedDescription ?? "error occur while deleting message")
                            
                            
                        } else {
                            
                            if messageID == groupModel.lastMessage.documentId {
                                
                                self.db.collection(Constant.FireBase.groupCollection).document(groupModel.groupID).updateData([
                                    kLastMessage: FieldValue.delete(),
                                ]) { err in
                                    if let err = err {
                                        print("Error updating document: \(err)")
                                    } else {
                                        print("Document successfully updated")
                                        self.addLastMessageInGroupCollcetion(groupModel: groupModel)
                                    }
                                }
                                
                            }
                            
                        }
                    }
                    
                } else {
                    
                    print(success)
                    
                }
                
            }
            
        }
        
        
    }
    
    
    /// add last message in group collection
    /// - Parameter groupModel: group model data
    func addLastMessageInGroupCollcetion(groupModel: GroupModel) {
        
        self.getGroupDocumentReference(GroupID: groupModel.groupID).collection(Constant.FireBase.messagesCollection).order(by: kCreatedAt,descending: true).addSnapshotListener { (QuerySnapshot, error) in
            
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            } else {
                
                guard let documents = QuerySnapshot?.documents else {
                    return
                }
                
                var arrMessage = [MessageModel]()
                
                arrMessage = documents.map({ (QueryDocumentSnapshot) -> MessageModel in
                    
                    let data = QueryDocumentSnapshot.data()
                    return MessageModel(dict: data)
                    
                })
                
                if arrMessage.isEmpty {
                    return
                } else {
                    
                    guard let lastMessage = arrMessage.first else {
                        return
                    }
                    
                    let messageData:[String:Any] = [kBody:lastMessage.body,kCreatedAt:lastMessage.createdAt,kUserName: lastMessage.userName,kDocumentId:lastMessage.documentId,kMessageType:lastMessage.messageType,kimageURL:lastMessage.imageURL]
                    
                    
                    let groupData:[String:Any] = [kGroupID: groupModel.groupID,kTitle: groupModel.title,kAdmin: groupModel.admin,kCreatedTimeStamp:groupModel.createdTimeStamp,kUserIds:groupModel.userIds,kLastMessage:messageData]
                    
                    
                    self.db.collection(Constant.FireBase.groupCollection).document(groupModel.groupID).setData(groupData, merge: true)
                    
                    print("successfull added new last message")
                    
                }
                
            }
            
            
        }
        
    }
    
    
    
    
    
    /// delete group
    /// - Warning: group only deleted by admin
    /// - Parameters:
    ///   - groupID: groupID of perticluar group
    ///   - completion: return success or failure
    func deleteGroup(groupID: String, completion: @escaping (Bool) -> Void) {
        
        db.collection(Constant.FireBase.groupCollection).document(groupID).delete { (error) in
            
            if error != nil {
                completion(false)
            } else {
                
                self.getGroupDocumentReference(GroupID: groupID).collection(kMessage).document().delete { (error) in
                    
                    if error != nil {
                        completion(false)
                    } else {
                        completion(true)
                    }
                    
                }
                
                
            }
            
        }
        
    }
    
    
    /// leave group
    /// - Warning: only leave by group's users, admin can't leave group
    /// - Parameters:
    ///   - groupID: groupID of perticluar group
    ///   - completion: return success or failure
    func leaveGroup(groupID: String,completion: @escaping (Bool) -> Void) {
        
        db.collection(Constant.FireBase.groupCollection).document(groupID).updateData([
            kUserIds: FieldValue.arrayRemove([UserModel.getCurrentUserID()])
        ]) { (error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "unable to add users")
                completion(false)
            } else {
                completion(true)
            }
            
        }
        
    }
}
