//
//  GroupChatViewModel.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 15/07/21.
//

import Foundation

class GroupChatViewModel: ObservableObject {
    
    @Published var navigation:String? = nil
    @Published var GroupNameTextField = ""
    @Published var arrOfUsers: [UserModel] = []
    @Published var arrOfSelectedUsers: [UserModel] = []
    @Published var imageName:String = "circle"
    @Published var createdGroup:GroupModel?
    @Published var updatedGroup = GroupModel()
    @Published var openSheet = false
    @Published var showingError = false
    @Published var errorMessage : String = ""
    
    private var db = Firestore.firestore()
    
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    
}

//MARK: - helper method
extension GroupChatViewModel {
    
    /// move to group listing screen
    func navTOGorupScreen() {
        self.navigation = IdentifiableKeys.NavigationTags.knavToGroupChat
    }
    
    
    
    /// add selected users/ members in selected group
    /// - Parameters:
    ///   - GroupID: selected group id
    ///   - arrayOfUsers: selected users
    ///   - completion: return nil
    func addButtonOFGroupChat(GroupID:String,arrayOfUsers:[String],completion: @escaping () -> Void) {
        
        arrOfSelectedUsers.removeAll()
        
        self.addUsersINGroup(addedUserList: arrayOfUsers, GroupID: GroupID, completion: {
            
            self.db.collection(Constant.FireBase.groupCollection).document(GroupID).getDocument { (DocumentSnapshot, error) in
                
                if error == nil {
                    
                    guard let document = DocumentSnapshot else {
                        return
                    }
                    
                    guard let documentData = document.data() else {
                        return
                    }
                    
                    let model = GroupModel(groupID: documentData[kGroupID] as? String ?? "", title: documentData[kTitle] as? String ?? "", createdTimeStamps: documentData[kCreatedTimeStamp] as? Double ?? 0, userIds: documentData[kUserIds] as? [String] ?? [""], adminString: documentData[kAdmin] as? String ?? "")
                    
                    self.updatedGroup = model
                    
                    completion()
                    
                    
                } else {
                    print(error?.localizedDescription as Any)
                    print("error occur")
                }
                
            }
            
            
        })
        
        
        
    }
    
    
    /// add selected users in group and create new group ( form selected user )
    func addButonOfOneToOneChat(selectedUser:UserModel,completion: @escaping () -> Void) {
        
        if self.GroupNameTextField != "" {
            
            arrOfSelectedUsers.removeAll()
            
            guard let currentUser = UserModel.getCurrentUserFromDefault() else {
                return
            }
            
            let temp = arrOfUsers.filter({$0.isSelected != false})
            arrOfSelectedUsers.append(selectedUser)
            arrOfSelectedUsers.append(currentUser)
            arrOfSelectedUsers.append(contentsOf:  temp)
            print(arrOfSelectedUsers.count)
            
            if arrOfSelectedUsers.count < 3 {
                self.showingError = true
                self.errorMessage = "AtLeast 3 users needed to create group"
            } else if arrOfSelectedUsers.count > 5 {
                self.showingError = true
                self.errorMessage = "Maximum 5 users only"
            } else {
                
                // create group
                self.createdGroup =  self.createGroup(users: arrOfSelectedUsers, AdminID: UserModel.getCurrentUserID())
                completion()
                
            }
            
        }  else {
            self.showingError = true
            self.errorMessage = "Please enter Group name"
        }
        
    }
    
    /// add selected users in group and create new group
    func addButtonForGroupLIstView(completion: @escaping () -> Void) {
        
        if self.GroupNameTextField != "" {
            
            arrOfSelectedUsers.removeAll()
            
            guard let currentUser = UserModel.getCurrentUserFromDefault() else {
                return
            }
            
            let temp = arrOfUsers.filter({$0.isSelected != false})
            
            arrOfSelectedUsers.append(currentUser)
            arrOfSelectedUsers.append(contentsOf:  temp)
            print(arrOfSelectedUsers.count)
            
            if arrOfSelectedUsers.count < 3 {
                self.showingError = true
                self.errorMessage = "AtLeast 3 users needed to create group"
            } else if arrOfSelectedUsers.count > 5 {
                self.showingError = true
                self.errorMessage = "Maximum 5 users only"
            } else {
                
                // create group
                self.createdGroup =  self.createGroup(users: arrOfSelectedUsers, AdminID: UserModel.getCurrentUserID())
                completion()
                
            }
            
            
        } else {
            
            self.showingError = true
            self.errorMessage = "Please enter Group name"
            
        }
        
    }
    
    
}


extension GroupChatViewModel {
    
    /// create new gorup
    /// - Parameters:
    ///   - users: list of users
    ///   - AdminID: admin user's id
    /// - Returns: return group data model ( return newly created group )
    func createGroup(users: [UserModel],AdminID:String) -> GroupModel {
        
        let documnetID = db.collection(Constant.FireBase.groupCollection).document().documentID
        
        var arrayOfUIds = [String]()
        
        for i in users {
            arrayOfUIds.append(i.uID)
        }
        
        let GroupData:[String:Any] = [kGroupID:documnetID,kCreatedTimeStamp:Date().UTCTimeStamp,kTitle:GroupNameTextField,kUserIds:arrayOfUIds,kAdmin:AdminID]
        
        db.collection(Constant.FireBase.groupCollection).document(documnetID).setData(GroupData)
        return GroupModel(dict: GroupData)
        
    }
    
    /// add users in group
    /// - Parameters:
    ///   - GroupID: selected groupId
    ///   - arrayOfSelectedUsers: selceted users
    ///   - completion: return success or failure
    func addUsersINGroup(GroupID: String,arrayOfSelectedUsers: [String], completion: @escaping (Bool) -> Void ){
        
        
        db.collection(Constant.FireBase.groupCollection).document(GroupID).updateData([
            kUserIds: FieldValue.arrayUnion(arrayOfSelectedUsers)
        ]) { (error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "unable to add users")
                completion(false)
            } else {
                completion(true)
            }
            
            
        }
        
        
    }
    
    /// get list of user's other than current login user
    func getUserListWithOutSelecetedUser() {
        
        db.collection(Constant.FireBase.userCollection).whereField(kUID, notIn: [UserModel.getCurrentUserID()]).addSnapshotListener { (QuerySnapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "error occur while fetching user's list")
                return
            } else {
                
                guard let documents = QuerySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                self.arrOfUsers = documents.map({ (queryDocumentSnapshot) -> UserModel in
                    let data = queryDocumentSnapshot.data()
                    
                    return UserModel(dictionary: data)
                    
                })
                
            }
        }
        
    }
    
    
    
    /// get list of user's other than current login user and selected user
    /// - Parameter selectedUserID: selected user's id
    func getUsersList(selectedUserID:String) {
        
        db.collection(Constant.FireBase.userCollection).addSnapshotListener { (QuerySnapshot, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "error occur while fetching user's list")
                return
            } else {
                
                guard let documents = QuerySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                self.arrOfUsers = documents.map({ (queryDocumentSnapshot) -> UserModel in
                    let data = queryDocumentSnapshot.data()
                    
                    return UserModel(dictionary: data)
                    
                })
                
                guard let currentuser = UserModel.getCurrentUserFromDefault() else { return }
                
                let tempArr = self.arrOfUsers
                var filterArray = tempArr.filter({$0.uID != currentuser.uID })
                filterArray = filterArray.filter({$0.uID != selectedUserID })
                self.arrOfUsers.removeAll()
                self.arrOfUsers.append(contentsOf: filterArray)
                
            }
            
        }
        
        
    }
    
    
    /// get list of user's who not in selected group
    /// - Parameters:
    ///   - addedUserList: already added user's id
    ///   - completion: return nil
    func getNotGroupUsersList(addedUserList:[String],completion: @escaping () -> Void) {
        
        db.collection(Constant.FireBase.userCollection).whereField(kUID, notIn: addedUserList).addSnapshotListener { (QuerySnapshot, error) in
            
            if error != nil {
                
                print(error?.localizedDescription ?? "error occur while fetching users data")
                return
                
            } else {
                
                guard let documents = QuerySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                self.arrOfUsers = documents.map({ (queryDocumentSnapshot) -> UserModel in
                    let data = queryDocumentSnapshot.data()
                    
                    return UserModel(dictionary: data)
                    
                })
                
                completion()
                
            }
            
            
            
        }
        
    }
    
    /// add users in current group
    ///  - Warning: only admin can add new user in selected group
    /// - Parameters:
    ///   - addedUserList: list of selected user's id
    ///   - GroupID: selected group
    ///   - completion: return nil
    func addUsersINGroup(addedUserList:[String],GroupID: String,completion: @escaping () -> Void) {
        
        
        var userArray: [UserModel] = []
        
        db.collection(Constant.FireBase.userCollection).whereField(kUID, in: addedUserList).addSnapshotListener { (QuerySnapshot, error) in
            
            if error != nil {
                
                print(error?.localizedDescription ?? "error occur while fteching users data")
                
            } else {
                
                guard let documents = QuerySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                userArray = documents.map({ (queryDocumentSnapshot) -> UserModel in
                    let data = queryDocumentSnapshot.data()
                    
                    return UserModel(dictionary: data)
                    
                })
                
                if self.arrOfSelectedUsers.count == addedUserList.count {
                    
                    self.showingError = true
                    self.errorMessage = "Please add alteast One new user in this group"
                    
                } else {
                    let temp = self.arrOfUsers.filter({$0.isSelected != false})
                    self.arrOfSelectedUsers.append(contentsOf: userArray)
                    self.arrOfSelectedUsers.append(contentsOf: temp)
                    
                    
                    if self.arrOfSelectedUsers.count > 5 {
                        self.showingError = true
                        self.errorMessage = "Maximum 5 users only"
                    } else {
                        
                        
                        var uIDArray = [String]()
                        
                        for i in self.arrOfSelectedUsers {
                            
                            uIDArray.append(i.uID)
                            
                        }
                        
                        self.addUsersINGroup(GroupID: GroupID, arrayOfSelectedUsers: uIDArray) { (success) in
                            
                            if !success {
                                
                                self.showingError = true
                                self.errorMessage = "unable to add users in this group \n please try agian later"
                                
                                
                            } else {
                                completion()
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        
        
    }
    
    
}
