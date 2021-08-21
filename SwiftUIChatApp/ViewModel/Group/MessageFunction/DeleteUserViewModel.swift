//
//  DeleteUserViewModel.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 20/07/21.
//

import Foundation

class DeleteUserViewModel: ObservableObject {
    
    @Published var arrUsers:[UserModel] = []
    @Published var arrOfSelectedUsers: [UserModel] = []
    @Published var updatedGroup = GroupModel()
    @Published var showingError = false
    @Published var errorMessage : String = ""
    
    private var db = Firestore.firestore()
    
}

extension DeleteUserViewModel {
    
    
    /// get list of user's other than current login user
    /// - Parameter groupModel: group model 
    func getUsers(groupModel: GroupModel?) {
        
        fetchGroupUsersID(groupModel: groupModel) { (arrUserID, success) in
            
            let currentUserID = UserModel.getCurrentUserID()
            
            let arryWithOutCurrentUser = arrUserID.filter({$0 != currentUserID})
            
            self.db.collection(Constant.FireBase.userCollection).whereField(kUID, in: arryWithOutCurrentUser).addSnapshotListener { (QuerySnapshot, error) in
                
                if error != nil {
                    
                    print(error?.localizedDescription ?? "error occur")
                    
                } else {
                    
                    guard let documents = QuerySnapshot?.documents else {
                        
                        return
                    }
                    
                    self.arrUsers = documents.map({ (QueryDocumentSnapshot) -> UserModel in
                        
                        let documnet = QueryDocumentSnapshot.data()
                        return UserModel(dictionary: documnet)
                        
                    })
                    
                    
                }
                
            }
            
        }
        
        
    }
    
    
    /// fetch all users for group
    /// - Parameters:
    ///   - groupModel: selected group
    ///   - completion: escaping with  array of user's id and success or failure
    func fetchGroupUsersID(groupModel: GroupModel?,completion: @escaping ([String],Bool) -> Void) {
        
        guard let model = groupModel else {
            return
        }
        
        db.collection(Constant.FireBase.groupCollection).document(model.groupID).addSnapshotListener { (DocumentSnapshot, error) in
            
            
            if error != nil {
                
                print(error?.localizedDescription ?? "error occur")
                
            } else {
                
                guard let document = DocumentSnapshot else {
                    completion([""],false)
                    return
                }
                
                if document.exists {
                    
                    guard let data = document.data() else {
                        completion([""],false)
                        return
                    }
                    
                    let userIDS = data[kUserIds] as? [String] ?? [""]
                    completion(userIDS,true)
                    
                    
                } else {
                    // completion false
                    completion([""],false)
                }
                
                
            }
            
            
        }
        
    }
    
    
    /// remove button action
    /// - Parameters:
    ///   - groupID: selected group id
    ///   - completion: escaping nil
    func addButtonAction(groupID: String,completion: @escaping () -> Void) {
        
        self.arrOfSelectedUsers.removeAll()
        let temp = arrUsers.filter({$0.isSelected != false})
        arrOfSelectedUsers.append(contentsOf:  temp)
        
        var arrOfUserID = [String]()
        for i in arrOfSelectedUsers {
            
            arrOfUserID.append(i.uID)
            
        }
        
        removeUserFormGroup(groupID: groupID, userIds: arrOfUserID) { (success) in
            if !success {
                
                self.showingError = true
                self.errorMessage = "unable to add users in this group \n please try agian later"
                
                
            } else {
                
                
                self.db.collection(Constant.FireBase.groupCollection).document(groupID).getDocument { (DocumentSnapshot, error) in
                    
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
                        self.showingError = true
                        self.errorMessage = "unable to add users in this group \n please try agian later"
                    }
                    
                    
                }
                
            }
        }
        
        
    }
    
    
    /// remove users form selected group
    /// - Parameters:
    ///   - groupID: selected group id
    ///   - userIds: selected user's id
    ///   - completion: return success or failure
    func removeUserFormGroup(groupID:String,userIds:[String],completion: @escaping (Bool) -> Void) {
        
        db.collection(Constant.FireBase.groupCollection).document(groupID).updateData([
            kUserIds: FieldValue.arrayRemove(userIds)
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
