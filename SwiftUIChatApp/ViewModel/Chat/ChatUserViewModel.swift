//
//  ChatUserViewModel.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 12/07/21.
//

import Foundation
import SwiftUI


//MARK: - ChatUserViewModel

class ChatUserListViewModel: ObservableObject {
    @Published var navigation:String? = nil
    @Published var showMenu = false
    @Published var showAlert = false
    @Published var userList: [UserModel] = []
    @Published var selectedUserModel: UserModel?
    @Published var isGridViewActive = false
    @Published var column = 1
    @Published var toolbarIcon: String = "square.grid.2x2"
    @Published var gridLayout: [GridItem] = [ GridItem(.flexible())]
    @Published var arrOfLastMessage:[String] = [""]
    
    private var db = Firestore.firestore()
    
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
}

//MARK: - helper methods
extension ChatUserListViewModel {
    
    /// grid switch animation action
    func GridSwitch() {
        gridLayout = Array(repeating: .init(.flexible()), count: gridLayout.count % 3 + 1)
        column = gridLayout.count
        print("grid Numbers: \(column)")
        
        // ToolBar Image
        switch column {
        case 1:
            toolbarIcon = "square.grid.2x2"
        case 2:
            toolbarIcon = "square.grid.3x2"
        case 3:
            toolbarIcon = "rectangle.grid.1x2"
        default:
            toolbarIcon = "square.grid.2x2"
        }
        
    }
    
    /// go to chat screen
    func moveToChat(completion:@escaping () -> Void) {
        
        
        self.navigation = IdentifiableKeys.NavigationTags.knavToChat
        completion()
        
    }
    
    
    /// logout form application and firebase
    func logOut() {
        
        changeActivityStatus {
            
            do {
                
                try Auth.auth().signOut()
                UserModel.removeUserFromDefault()
                UserDefaults.isRegisteredUserLogin = false
                self.navigation = IdentifiableKeys.NavigationTags.kNavToLogin
                
            } catch {
                print(error.localizedDescription)
            }
        }
        
       
    }
    
    /// make current user offline
    func changeActivityStatus(completion: @escaping () -> Void) {
        let currentUserID = UserModel.getCurrentUserID()
        let isOnlineData = [kIsOnline:false]
        self.db.collection(Constant.FireBase.userCollection).document(currentUserID).setData(isOnlineData, merge: true) { (error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
                completion()
                
            } else {
                print("sucessfully change status")
                completion()
            }
            
        }
        
    }
    
    /// sidemenu action
    func moveToOtherView() {
        
        switch sideMenuGlobalVariable {
        case "Home":
            self.navigation = IdentifiableKeys.NavigationTags.knavToHome
        case "Chat":
            self.navigation = IdentifiableKeys.NavigationTags.knavToChatUser
        case "Group":
            self.navigation = IdentifiableKeys.NavigationTags.knavToGroupList
        case "Logout":
            self.showMenu = false
            self.showAlert.toggle()
            
        default:
            break
        }
        
    }
    
    /// to show sideMenu
    func parentFunction() {
        self.showMenu = true
    }
    
    
}

//MARK: - users List
extension ChatUserListViewModel {
    
    
    /// get user's id form converstaion collection
    ///  only return user's id who already done conversation with current uesr
    /// - Parameter completion: return success or faliure , userld's array and array of coversationModel
    func getUserIDFormCollection(completion: @escaping (Bool , [String],[ConversationModel]?) -> Void) {
        
        
        let currentUserID = UserModel.getCurrentUserID()
        
        var usersID = [String]()
        
        db.collection(Constant.FireBase.conversationCollection).whereField(kUserIds, arrayContains: currentUserID).addSnapshotListener { (QuerySnapshot, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "error ocur while fetching chatData 1")
                completion(false , [""], nil)
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
                completion(true, usersID, arrOfConversation)
                
                
                
            }
            
            
        }
        
    }
    
    
    
    /// get all user's details who already done conversation with current users
    func getUsers() {
        
        getUserIDFormCollection { (success, userID,arrOfCoversation)  in
            
            if success {
                
                if userID.isEmpty {
                    return
                }
                
                guard let arrCov = arrOfCoversation else {
                    return
                }
                
                
                self.db.collection(Constant.FireBase.userCollection).whereField(kUID, in: userID).addSnapshotListener { (QuerySnapshot, error) in
                    if error != nil {
                        print(error?.localizedDescription ?? "error ocur while fetching userData")
                    } else {
                        
                        self.userList.removeAll()
                        guard let documents = QuerySnapshot?.documents else {
                            print("No documents")
                            return
                        }
                        
                        self.userList = documents.map({ (QueryDocumentSnapshot) -> UserModel in
                            let data = QueryDocumentSnapshot.data()
                            return UserModel(dictionary: data)
                        })
                        
                        guard let currentuser = UserModel.getCurrentUserFromDefault() else {
                            return
                        }
                        
                        
                        
                        for i in 0...arrCov.count - 1 {
                            
                            var senderUser = String()
                            
                            if arrCov[i].lastMessage.userId == UserModel.getCurrentUserID() {
                                senderUser = "\(currentuser.firstName) \(currentuser.lastName)"
                            } else {
                                senderUser = "\(self.userList[i].firstName) \(self.userList[i].lastName)"
                            }
                            
                            if arrCov[i].lastMessage.messageType == 1 {
                                
                                let message = "\(senderUser): \(arrCov[i].lastMessage.body)"
                                self.userList[i].lastMessageString = message
                                
                                
                            } else if arrCov[i].lastMessage.messageType == 2 {
                                
                                let message = "\(senderUser): 🌄"
                                self.userList[i].lastMessageString = message
                                
                            } else if arrCov[i].lastMessage.messageType == 3 {
                                let message = "\(senderUser): 🌄 \(arrCov[i].lastMessage.body)"
                                self.userList[i].lastMessageString = message
                            }
                            
                            if arrCov[i].lastMessage.body == "" && arrCov[i].lastMessage.imageURL == "" {
                                let message = ""
                                self.userList[i].lastMessageString = message
                                self.userList[i].dateString = Date().getDateStringFromUTC2(timeStamp: Int64(arrCov[i].createdTimeStamp))
                            } else {
                                self.userList[i].dateString = Date().getDateStringFromUTC2(timeStamp: Int64(arrCov[i].lastMessage.createdAt))
                            }
                            
                        }
                        
                        
                        
                    }
                }
                
            } else {
                return
            }
            
        }
        
        
    }
    
}
