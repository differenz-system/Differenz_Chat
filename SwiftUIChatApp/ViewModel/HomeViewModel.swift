//
//  HomeViewModel.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 09/07/21.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    
    @Published var navigation:String? = nil
    @Published var arrOfGroup: [GroupModel] = []
    @Published var userList: [UserModel] = []
    @Published var otherUsers: [UserModel] = []
    @Published var showMenu = false
    @Published var showAlert = false
    @Published var selectedUserModel: UserModel?
    @Published var selectedGroupModel: GroupModel?
    @Published var isGridViewActive = false
    @Published var column = 1
    @Published var toolbarIcon: String = "square.grid.2x2"
    @Published var gridLayout: [GridItem] = [ GridItem(.flexible())]
    
    private var db = Firestore.firestore()
    
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
}


//MARK: - Helper method
extension HomeViewModel {
    
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
    
    ///  move to chat screen
    /// - Parameters:
    ///   - isGroup: if group is selcted or not
    ///   - completion: escaping with nil
    func moveToChat(isGroup:Bool,completion:@escaping () -> Void) {
        
        if isGroup {
            self.navigation = IdentifiableKeys.NavigationTags.knavToGroupChat
        } else {
            self.navigation = IdentifiableKeys.NavigationTags.knavToChat
        }
        
        completion()
        
    }
    
    /// logout form firebase and application
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
    func changeActivityStatus(makeUserInActive:Bool = true , completion: @escaping () -> Void) {
        let currentUserID = UserModel.getCurrentUserID()
        let isOnlineData = [kIsOnline: makeUserInActive ? false : true]
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
    
    
    /// sidemenu button action
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
    
    /// to show sidemenu
    func parentFunction() {
        self.showMenu = true
    }
    
    
}

//MARK: - Firebase function
extension HomeViewModel {
    
    /// Get UserId From Collection
    /// - Parameter completion: escaping with success or failure , array of user's id and conversation model
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
    
    
    /// get  chat users data
    /// - Parameter completion: escaping with nil
    func getChatUsers(completion: @escaping () -> Void) {
        
        getUserIDFormCollection { (success, userID,arrOfCoversation)  in
            
            if success {
                
                if userID.isEmpty {
                    completion()
                    return
                }
                
                guard let arrCov = arrOfCoversation else {
                    completion()
                    return
                }
                
                self.db.collection(Constant.FireBase.userCollection).whereField(kUID, in: userID).addSnapshotListener { (QuerySnapshot, error) in
                    if error != nil {
                        print(error?.localizedDescription ?? "error ocur while fetching userData")
                        completion()
                        return
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
                            completion()
                            return
                        }
                        
                        
                        
                        
                        /// set last message
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
                        
                        completion()
                        
                    }
                }
                
            } else {
                completion()
                return
            }
            
        }
        
        
    }
    
    
    /// Fetech other users
    /// yet to do chat with them
    /// - Parameter completion: escaping nil
    func getOtherUsers(completion: @escaping () -> Void) {
        
        var arrUsersUID = [String]()
        
        if !self.userList.isEmpty {
            
            for user in self.userList {
                arrUsersUID.append(user.uID)
            }
            
            self.db.collection(Constant.FireBase.userCollection).whereField(kUID, notIn: arrUsersUID).addSnapshotListener { (querySnapshot, error) in
                
                if error != nil {
                    print(error?.localizedDescription as Any)
                    completion()
                    return
                } else {
                    
                    guard let documents = querySnapshot?.documents else {
                        completion()
                        return
                    }
                    
                    self.otherUsers = documents.map({ (queryDocumentSnapshot) -> UserModel in
                        let data = queryDocumentSnapshot.data()
                        
                        return UserModel(dictionary: data)
                    })
                    
                    /// remove current user
                    let tempArr = self.otherUsers
                    let filterArray = tempArr.filter({$0.uID != UserModel.getCurrentUserID() })
                    self.otherUsers.removeAll()
                    self.otherUsers.append(contentsOf: filterArray)
                    completion()
                }
                
            }
            
        } else {
            
            getAllUsers()
        }
    }
    
    /// Fetch all users
    func getAllUsers() {
        
        db.collection(Constant.FireBase.userCollection).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.otherUsers = documents.map({ (queryDocumentSnapshot) -> UserModel in
                let data = queryDocumentSnapshot.data()
                
                return UserModel(dictionary: data)
                
            })
            
            guard let currentuser = UserModel.getCurrentUserFromDefault() else { return }
            
            /// remove current user
            let tempArr = self.otherUsers
            let filterArray = tempArr.filter({$0.uID != currentuser.uID })
            self.otherUsers.removeAll()
            self.otherUsers.append(contentsOf: filterArray)
            
            
        }
        
        
    }
    
    /// Fetch list of  group
    func fetchListOfGroup(completion: @escaping () -> Void) {
        
        let currentUserID = UserModel.getCurrentUserID()
        
        db.collection(Constant.FireBase.groupCollection).whereField(kUserIds, arrayContains: currentUserID).addSnapshotListener { (QuerySnapshot, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "error occur while fetching data")
                completion()
                return
            } else {
                
                self.arrOfGroup.removeAll()
                
                guard let documents = QuerySnapshot?.documents else {
                    print("No documents")
                    completion()
                    return
                }
                
                self.arrOfGroup = documents.map({ (QueryDocumentSnapshot) -> GroupModel in
                    let document = QueryDocumentSnapshot.data()
                    return GroupModel(dict: document)
                })
                
                /// to show  last message in group
                /*
                 1 - text
                 2 - image
                 3 - image and text
                 */
                for group in self.arrOfGroup {
                    
                    if group.lastMessage.messageType == 1 {
                        
                        group.lastMessageString = "\(group.lastMessage.userName): \(group.lastMessage.body)"
                        
                    } else if group.lastMessage.messageType == 2 {
                        
                        group.lastMessageString = "\(group.lastMessage.userName): 🌄"
                        
                    } else if group.lastMessage.messageType == 3 {
                        
                        group.lastMessageString = "\(group.lastMessage.userName): 🌄 \(group.lastMessage.body)"
                    }
                    
                    if group.lastMessage.body == "" && group.lastMessage.imageURL == "" {
                        
                        group.lastMessageString = ""
                        group.dateString = Date().getDateStringFromUTC2(timeStamp: Int64(group.createdTimeStamp))
                    } else {
                        group.dateString = Date().getDateStringFromUTC2(timeStamp: Int64(group.lastMessage.createdAt))
                    }
                    
                }
                completion()
                
            }
            
            
        }
        
    }
    
}


//MARK: - widget data
extension HomeViewModel {
    
    /// send date to widget
//    func sendDataToWidget(){
//        
//        
//        if self.arrOfGroup.isEmpty || self.userList.isEmpty {
//            return
//        }
//        
//        var arrOfusers: [UserModel] = []
//        var arrOfGroup: [GroupModel] = []
//        
//        if self.userList.count > 7 {
//            
//            let trimArrayUser = Array(self.userList.prefix(7))
//            arrOfusers = trimArrayUser
//        
//        } else {
//            
//            arrOfusers = self.userList
//        }
//        
//        if self.arrOfGroup.count > 7 {
//            
//            let trimArrayOfGroup = Array(self.arrOfGroup.prefix(7))
//            arrOfGroup = trimArrayOfGroup
//            
//        } else {
//            arrOfGroup = self.arrOfGroup
//        }
//        
//        let widgetData: [String:Any] = [kArrOfUsers:arrOfusers,kArrOfGroups:arrOfGroup]
//
//        let widgetObj = WidgetDataModel(dictionary: widgetData)
//        widgetObj.saveCurrentUserInDefault()
//        
//        guard let printWidget = WidgetDataModel.getWidgetData() else {
//            print("error while saving data")
//            return
//        }
//        
//        let arrOfUsersData = printWidget.arrOfUsers
//        let arrOfGroupData = printWidget.arrOfGroups
//        
//        for i in arrOfUsersData {
//            
//            print("\(i.firstName) \(i.lastName)")
//            
//        }
//        
//        for j in arrOfGroupData {
//            print("\(j.title)")
//        }
//        
//    }
    
    
}
