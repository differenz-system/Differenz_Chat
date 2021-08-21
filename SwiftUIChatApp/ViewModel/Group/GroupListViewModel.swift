//
//  GroupListViewModel.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 16/07/21.
//

import Foundation
import SwiftUI

class GroupListViewModel: ObservableObject {
    
    @Published var openSheet = false
    @Published var navigation:String? = nil
    @Published var arrOfGroup:[GroupModel] = []
    @Published var showMenu = false
    @Published var showAlert = false
    @Published var selectedGroup:GroupModel?
    @Published var isGridViewActive = false
    @Published var column = 1
    @Published var toolbarIcon: String = "square.grid.2x2"
    @Published var gridLayout: [GridItem] = [ GridItem(.flexible())]
    
    private var db = Firestore.firestore()
    
    
}

extension GroupListViewModel {
    
    
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
    
    /// got o chat screen
    func moveToChat(completion: @escaping () -> Void) {
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
    
    /// to show sidemenu
    func parentFunction() {
        self.showMenu = true
    }
    
}

//MARK: - List of group
extension GroupListViewModel {
    
    
    /// fetch list of groups
    func fetchListOfGroup() {
        
        let currentUserID = UserModel.getCurrentUserID()
        
        db.collection(Constant.FireBase.groupCollection).whereField(kUserIds, arrayContains: currentUserID).addSnapshotListener { (QuerySnapshot, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "error occur while fetching data")
            } else {
                
                self.arrOfGroup.removeAll()
                
                guard let documents = QuerySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                self.arrOfGroup = documents.map({ (QueryDocumentSnapshot) -> GroupModel in
                    let document = QueryDocumentSnapshot.data()
                    return GroupModel(dict: document)
                })
                
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
                
            }
            
            
        }
        
    }
    
}
