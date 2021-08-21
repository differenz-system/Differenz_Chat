//
//  ForwardLIstViewModel.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 27/07/21.
//

import Foundation

class ForwardLIstViewModel: ObservableObject {
    
    @Published var arrGorup:[GroupModel] = []
    @Published var arrChatUsers:[UserModel] = []
    @Published var arrNotChatUsers:[UserModel] = []
    @Published var showAlert = false
    @Published var errorMessage = ""
    @Published var showLoader = false
    var storageVM = firebaseStorageViewModel()
    
    private var db = Firestore.firestore()
    
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
}

//MARK: - helper methods
extension ForwardLIstViewModel {
    
    
    /// get all user' s who yrt to do conversation with current user
    /// - Parameter completion: return success or failure
    func getAllUsersNotChatWIthMe(completion: @escaping (Bool) -> Void) {
        
        getUserIDFormCollection { (success, arrUser) in
            
            if success {
                
                var arrOfChatListusers = arrUser
                arrOfChatListusers.append(UserModel.getCurrentUserID())
                
                self.db.collection(Constant.FireBase.userCollection).whereField(kUID, notIn: arrOfChatListusers).addSnapshotListener { (QuerySnapshot, error) in
                    if error != nil {
                        
                        completion(false)
                        
                    } else {
                        
                        self.arrNotChatUsers.removeAll()
                        
                        guard let documents = QuerySnapshot?.documents else {
                            print("No documents")
                            completion(true)
                            return
                        }
                        
                        self.arrNotChatUsers = documents.map({ (QueryDocumentSnapshot) -> UserModel in
                            let data = QueryDocumentSnapshot.data()
                            return UserModel(dictionary: data)
                        })
                        completion(true)
                        
                    }
                }
                
                
            } else {
                completion(success)
            }
            
        }
        
    }
    
    
    /// get all users who already done conversation with current user
    /// - Parameters:
    ///   - UserID: userID
    ///   - completion:  return success or failure
    func getAllUserWhoChatWithMe(alreadyShared UserID:String = "",completion: @escaping (Bool) -> Void) {
        
        getUserIDFormCollection { (sucess, arrUser) in
            
            if sucess {
                
                if arrUser.isEmpty {
                    completion(sucess)
                }
                
                let arrusersChat = arrUser.filter({$0 != UserID})
                
                if arrusersChat.isEmpty {
                    completion(true)
                    return
                }
                
                self.db.collection(Constant.FireBase.userCollection).whereField(kUID, in: arrusersChat).addSnapshotListener { (QuerySnapshot, error) in
                    
                    if error != nil {
                        
                        completion(false)
                        
                    } else {
                        
                        self.arrChatUsers.removeAll()
                        
                        guard let documents = QuerySnapshot?.documents else {
                            print("No documents")
                            completion(true)
                            return
                        }
                        
                        self.arrChatUsers = documents.map({ (QueryDocumentSnapshot) -> UserModel in
                            let data = QueryDocumentSnapshot.data()
                            return UserModel(dictionary: data)
                        })
                        completion(true)
                    }
                    
                }
                
                
            } else {
                completion(sucess)
            }
            
        }
        
    }
    
    
    /// return list of users who do conversation with current user
    /// - Parameter completion: return success or failure and list of userIds
    func getUserIDFormCollection(completion: @escaping (Bool , [String]) -> Void) {
        
        
        let currentUserID = UserModel.getCurrentUserID()
        
        var usersID = [String]()
        
        db.collection(Constant.FireBase.conversationCollection).whereField(kUserIds, arrayContains: currentUserID).addSnapshotListener { (QuerySnapshot, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "error ocur while fetching chatData 1")
                completion(false , [""])
            } else {
                
                usersID.removeAll()
                
                guard let documents = QuerySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                var arrOfConversation = [ConversationModel]()
                
                arrOfConversation = documents.map({ (QueryDocumentSnapshot) -> ConversationModel in
                    
                    let documnet = QueryDocumentSnapshot.data()
                    return ConversationModel(dict: documnet)
                    
                })
                
                for conversation in arrOfConversation {
                    
                    usersID.append(contentsOf: conversation.userIds)
                }
                
                let tempArr = usersID
                usersID.removeAll()
                usersID = tempArr.filter({$0 != currentUserID})
                completion(true, usersID)
                
                
                
            }
            
            
        }
        
    }
    
    
    /// get list of group which groups current join or created
    /// - Parameters:
    ///   - groupID: filter group which message going to be shared
    ///   - completion: return success or failure
    func getAllGroupWhoIAmIn(selectedGroup groupID:String = "",completion:@escaping (Bool) -> Void) {
        
        let currentUserID = UserModel.getCurrentUserID()
        
        db.collection(Constant.FireBase.groupCollection).whereField(kUserIds, arrayContains: currentUserID).addSnapshotListener { (QuerySnapshot, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "error occur while fetching data")
                completion(false)
            } else {
                
                self.arrGorup.removeAll()
                
                guard let documents = QuerySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                self.arrGorup = documents.map({ (QueryDocumentSnapshot) -> GroupModel in
                    let document = QueryDocumentSnapshot.data()
                    return GroupModel(dict: document)
                })
                
                
                
                self.arrGorup = self.arrGorup.filter({$0.groupID != groupID})
                
                completion(true)
                
            }
            
            
        }
        
    }
    
    
    /// to generate conversation Id
    /// - Parameters:
    ///   - senderID: sender id
    ///   - receriverID: receriver id
    /// - Returns: return generated conversation id
    func getConversationID(senderID: String,receriverID: String) -> String {
        
        var conversationID = ""
        
        if senderID > receriverID {
            conversationID = "\(senderID)_\(receriverID)"
        } else {
            conversationID = "\(receriverID)_\(senderID)"
        }
        
        return conversationID
    }
    
    
    /// generate path of collection's document
    /// - Parameters:
    ///   - collectionName: collection name
    ///   - collectionId: collectionID
    /// - Returns: return path of document
    func getConversationDocumentReference(collectionName:String,collectionId: String) -> DocumentReference {
        
        db.collection(collectionName)
            .document(collectionId)
        
    }
    
    /// forward message to users or group
    /// - Parameters:
    ///   - message: message data model
    ///   - completion: return nil
    func forwradMessage(message: MessageModel,completion: @escaping () -> Void) {
        
        var arrayCount = 0
        
        let selectedGroup = self.arrGorup.filter({$0.isSelected == true})
        let selectedChatUsers = self.arrChatUsers.filter({$0.isSelected == true})
        let selectedNewUsers = self.arrNotChatUsers.filter({$0.isSelected == true})
        
        arrayCount = selectedGroup.count + selectedChatUsers.count + selectedNewUsers.count
        
        if arrayCount == 0 {
            
            showAlert = true
            errorMessage = "Please share atleast one message"
            
        } else if arrayCount > 5 {
            
            showAlert = true
            errorMessage = "only allow 5 messages at a time"
            
        } else {
            
            var selectedGroupID = [String]()
            
            for i in selectedGroup {
                selectedGroupID.append(i.groupID)
            }
            
            var selectedChatUser = [String]()
            
            for i in selectedChatUsers {
                selectedChatUser.append(i.uID)
            }
            
            var newUsersID = [String]()
            
            for i in selectedNewUsers {
                newUsersID.append(i.uID)
            }
            
            let messageData:[String:Any] = [kBody:message.body,kCreatedAt:message.createdAt,kUserId:message.userId,kDocumentId:message.documentId,kUserName:message.userName,kMessageType:message.messageType,kimageURL:message.imageURL]
            
            guard let currentUser = UserModel.getCurrentUserFromDefault() else {
                return
            }
            
            let currentUserName = "\(currentUser.firstName) \(currentUser.lastName)"
            
            // send message process
            
            self.showLoader = true
            shareMessageINGroup(currentUserName: currentUserName, message: messageData, selectedGroupID: selectedGroupID, selectedGroups: selectedGroup) { (groupResult) in
                
                self.shareMessageWithUsers(currentUserName: currentUserName, message: messageData, selectedUsersID: selectedChatUser, selectedUsersList: selectedChatUsers) { (chatUserResult) in
                    
                    
                    self.shareMessageWithOthers(currentUserName: currentUserName, message: messageData, selectedusersID: newUsersID, selectedUsersList: selectedNewUsers) { (otherChatResult) in
                        self.showLoader = false
                        completion()
                        
                    }
                    
                }
                
                
            }
            
        }
        
    }
    
    
    
    /// helper method of forward message function
    ///  to share message in group
    /// - Parameters:
    ///   - currentUserName: current user name
    ///   - message: message data
    ///   - selectedGroupID: selected group's ID
    ///   - selectedGroups: selected group
    ///   - completion: return nil
    func shareMessageINGroup(currentUserName:String, message: [String:Any],selectedGroupID: [String],selectedGroups: [GroupModel],completion: @escaping (Bool) -> Void) {
        
        if selectedGroupID.isEmpty {
            completion(false)
            return
        }
        
        var messageData = message
        
        messageData[kUserId] = UserModel.getCurrentUserID()
        messageData[kUserName] = currentUserName
        
        let messageType = message[kMessageType] as? Int ?? 1
        
        if messageType == 1 {
            
            for i in 0...selectedGroupID.count - 1 {
                
                let documentID = self.getConversationDocumentReference(collectionName: Constant.FireBase.groupCollection, collectionId: selectedGroupID[i]).collection(Constant.FireBase.messagesCollection).document().documentID
                
                messageData[kDocumentId] = documentID
                messageData[kCreatedAt] = Date().UTCTimeStamp
                
                
                self.getConversationDocumentReference(collectionName: Constant.FireBase.groupCollection, collectionId: selectedGroupID[i]).collection(Constant.FireBase.messagesCollection).document(documentID).setData(messageData)
                
                let updatedGroupData:[String:Any] = [kGroupID:selectedGroups[i].groupID,kTitle:selectedGroups[i].title,kAdmin:selectedGroups[i].admin,kCreatedTimeStamp:selectedGroups[i].createdTimeStamp,kUserIds:selectedGroups[i].userIds,kLastMessage:messageData]
                self.getConversationDocumentReference(collectionName: Constant.FireBase.groupCollection, collectionId: selectedGroupID[i]).setData(updatedGroupData, merge: true)
                
                
            }
            completion(true)
            
        } else if messageType == 2 || messageType == 3 {
            
            let messageURL = messageData[kimageURL] as? String ?? ""
            
            for i in 0...selectedGroupID.count - 1 {
                
                storageVM.uploadFile(folderName: folderName.kSharedFolder,fileURL: URL(string: messageURL)!) { (success, newImageURL) in
                    
                    if success {
                        
                        messageData[kimageURL] = newImageURL
                        
                        let documentID = self.getConversationDocumentReference(collectionName: Constant.FireBase.groupCollection, collectionId: selectedGroupID[i]).collection(Constant.FireBase.messagesCollection).document().documentID
                        
                        messageData[kDocumentId] = documentID
                        messageData[kCreatedAt] = Date().UTCTimeStamp
                        
                        
                        self.getConversationDocumentReference(collectionName: Constant.FireBase.groupCollection, collectionId: selectedGroupID[i]).collection(Constant.FireBase.messagesCollection).document(documentID).setData(messageData)
                        
                        let updatedGroupData:[String:Any] = [kGroupID:selectedGroups[i].groupID,kTitle:selectedGroups[i].title,kAdmin:selectedGroups[i].admin,kCreatedTimeStamp:selectedGroups[i].createdTimeStamp,kUserIds:selectedGroups[i].userIds,kLastMessage:messageData]
                        self.getConversationDocumentReference(collectionName: Constant.FireBase.groupCollection, collectionId: selectedGroupID[i]).setData(updatedGroupData, merge: true)
                        
                        completion(true)
                        
                    } else {
                        completion(false)
                        return
                    }
                    
                }
                
            }
            
        }
        
        
    }
    
    /// helper message of forward message function.
    /// used to share message with users who already done conversation with current user
    /// - Parameters:
    ///   - currentUserName: current user's full name
    ///   - message: message data
    ///   - selectedUsersID: selected user's id
    ///   - selectedUsersList: selected user's data
    ///   - completion: return nil
    func shareMessageWithUsers(currentUserName: String, message: [String:Any],selectedUsersID: [String],selectedUsersList:[UserModel],completion: @escaping (Bool) -> Void) {
        
        if selectedUsersID.isEmpty {
            
            completion(false)
            return
        }
        
        var messageData = message
        
        messageData[kUserId] = UserModel.getCurrentUserID()
        messageData[kUserName] = currentUserName
        
        let messageType = message[kMessageType] as? Int ?? 1
        
        if messageType == 1 {
            
            for i in 0...selectedUsersID.count - 1 {
                
                let conversationID = self.getConversationID(senderID: UserModel.getCurrentUserID(), receriverID: selectedUsersID[i])
                
                
                db.collection(Constant.FireBase.conversationCollection).document(conversationID).getDocument { (DocumentSnapshot, error) in
                    
                    if error != nil {
                        
                        completion(false)
                        return
                        
                    } else {
                        
                        let documentID = self.getConversationDocumentReference(collectionName: Constant.FireBase.conversationCollection, collectionId: conversationID).collection(Constant.FireBase.messagesCollection).document().documentID
                        
                        messageData[kDocumentId] = documentID
                        messageData[kCreatedAt] = Date().UTCTimeStamp
                        
                        self.getConversationDocumentReference(collectionName: Constant.FireBase.conversationCollection, collectionId: conversationID).collection(Constant.FireBase.messagesCollection).document(documentID).setData(messageData)
                        
                        guard let document = DocumentSnapshot else {
                            return
                        }
                        
                        guard let documnetData = document.data() else {
                            completion(false)
                            return
                        }
                        
                        let timestamp = documnetData[kCreatedTimeStamp] as? Double ?? 0
                        let usersIDs = documnetData[kUserIds] as? [String] ?? [""]
                        
                        let conversationData:[String:Any] = [kConversationID:conversationID,kCreatedTimeStamp:timestamp,kUserIds:usersIDs,kLastMessage:messageData]
                        self.db.collection(Constant.FireBase.conversationCollection).document(conversationID).setData(conversationData,merge: true)
                        
                    }
                    
                    
                }
                
                
            }
            completion(true)
            
        } else if messageType == 2 || messageType == 3  {
            
            let messageURL = messageData[kimageURL] as? String ?? ""
            
            for i in 0...selectedUsersID.count - 1 {
                
                storageVM.uploadFile(folderName: folderName.kSharedFolder, fileURL: URL(string: messageURL)!) { (success, newImageURL) in
                    
                    if success {
                        
                        messageData[kimageURL] = newImageURL
                        
                        let conversationID = self.getConversationID(senderID: UserModel.getCurrentUserID(), receriverID: selectedUsersID[i])
                        
                        
                        self.db.collection(Constant.FireBase.conversationCollection).document(conversationID).getDocument { (DocumentSnapshot, error) in
                            
                            if error != nil {
                                completion(false)
                                return
                            } else {
                                let documentID = self.getConversationDocumentReference(collectionName: Constant.FireBase.conversationCollection, collectionId: conversationID).collection(Constant.FireBase.messagesCollection).document().documentID
                                
                                messageData[kDocumentId] = documentID
                                messageData[kCreatedAt] = Date().UTCTimeStamp
                                
                                self.getConversationDocumentReference(collectionName: Constant.FireBase.conversationCollection, collectionId: conversationID).collection(Constant.FireBase.messagesCollection).document(documentID).setData(messageData)
                                
                                guard let document = DocumentSnapshot else {
                                    return
                                }
                                
                                guard let documnetData = document.data() else {
                                    completion(false)
                                    return
                                }
                                
                                let timestamp = documnetData[kCreatedTimeStamp] as? Double ?? 0
                                let usersIDs = documnetData[kUserIds] as? [String] ?? [""]
                                
                                let conversationData:[String:Any] = [kConversationID:conversationID,kCreatedTimeStamp:timestamp,kUserIds:usersIDs,kLastMessage:messageData]
                                self.db.collection(Constant.FireBase.conversationCollection).document(conversationID).setData(conversationData,merge: true)
                            }
                            
                            
                        }
                        
                        
                        completion(true)
                        
                    } else {
                        completion(false)
                        return
                    }
                    
                }
                
            }
            
            
        }
        
    }
    
    
    
    /// helper method of share message function.
    /// share message with those user's who yet to do conversation with current users
    /// - Parameters:
    ///   - currentUserName: cuurent user's full name
    ///   - message: message data
    ///   - selectedusersID: selected user's id
    ///   - selectedUsersList: selected user's data
    ///   - completion: return success or faliure
    func shareMessageWithOthers(currentUserName: String,message: [String:Any],selectedusersID: [String],selectedUsersList:[UserModel],completion: @escaping (Bool) -> Void) {
        
        if selectedusersID.isEmpty {
            completion(false)
            return
        }
        
        var messageData = message
        messageData[kUserId] = UserModel.getCurrentUserID()
        messageData[kUserName] = currentUserName
        
        let messageType = message[kMessageType] as? Int ?? 1
        
        if messageType == 1 {
            
            for i in 0...selectedusersID.count - 1 {
                
                let conversactionID = self.getConversationID(senderID: UserModel.getCurrentUserID(), receriverID: selectedusersID[i])
                
                let DocumentID = self.getConversationDocumentReference(collectionName: Constant.FireBase.conversationCollection, collectionId: conversactionID).collection(Constant.FireBase.messagesCollection).document().documentID
                
                messageData[kDocumentId] = DocumentID
                messageData[kCreatedAt] = Date().UTCTimeStamp
                
                self.getConversationDocumentReference(collectionName: Constant.FireBase.conversationCollection, collectionId: conversactionID).collection(Constant.FireBase.messagesCollection).document(DocumentID).setData(messageData)
                
                
                let conversationData:[String:Any] = [kConversationID:conversactionID,kCreatedTimeStamp:Date().UTCTimeStamp,kUserIds:[UserModel.getCurrentUserID(),selectedusersID[i]],kLastMessage:messageData]
                self.db.collection(Constant.FireBase.conversationCollection).document(conversactionID).setData(conversationData)
                
                
                
                completion(true)
            }
            
            
        } else if messageType == 2 || messageType == 3 {
            
            let messageURL = messageData[kimageURL] as? String ?? ""
            
            for i in 0...selectedusersID.count - 1 {
                
                storageVM.uploadFile(folderName: folderName.kSharedFolder, fileURL: URL(string: messageURL)!) { (success, newImageURL) in
                    
                    if success {
                        
                        let conversactionID = self.getConversationID(senderID: UserModel.getCurrentUserID(), receriverID: selectedusersID[i])
                        
                        messageData[kimageURL] = newImageURL
                        
                        let DocumentID = self.getConversationDocumentReference(collectionName: Constant.FireBase.conversationCollection, collectionId: conversactionID).collection(Constant.FireBase.messagesCollection).document().documentID
                        
                        messageData[kDocumentId] = DocumentID
                        messageData[kCreatedAt] = Date().UTCTimeStamp
                        
                        self.getConversationDocumentReference(collectionName: Constant.FireBase.conversationCollection, collectionId: conversactionID).collection(Constant.FireBase.messagesCollection).document(DocumentID).setData(messageData)
                        
                        let conversationData:[String:Any] = [kConversationID:conversactionID,kCreatedTimeStamp:Date().UTCTimeStamp,kUserIds:[UserModel.getCurrentUserID(),selectedusersID[i]],kLastMessage:messageData]
                        self.db.collection(Constant.FireBase.conversationCollection).document(conversactionID).setData(conversationData)
                        
                        completion(true)
                        
                    } else {
                        
                        completion(false)
                        return
                    }
                    
                }
                
            }
            
        }
        
        
    }
    
    
}
