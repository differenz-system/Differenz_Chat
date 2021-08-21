//
//  GroupUserListViewModel.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 20/07/21.
//

import Foundation

class GroupUserListViewModel: ObservableObject {
    
    @Published var arrusers:[UserModel] = []
    @Published var selectedUser = UserModel()
    
    private var db = Firestore.firestore()
    
}

//MARK: - helper methods
extension GroupUserListViewModel {
    
    
    /// go to chat screen
    /// - Parameters:
    ///   - userModel: user data model
    ///   - completion: return nil
    func moveToChat(userModel:UserModel,completion: @escaping () -> Void) {
        selectedUser = userModel
        completion()
    }
    
    
    
    
    
}

//MARK: - group listing
extension GroupUserListViewModel {
    
    /// get user list data who join current group
    /// - Parameter groupModel: group data model
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
                    
                    self.arrusers = documents.map({ (QueryDocumentSnapshot) -> UserModel in
                        
                        let documnet = QueryDocumentSnapshot.data()
                        return UserModel(dictionary: documnet)
                        
                    })
                    
                }
                
            }
            
        }
        
        
    }
    
    
    /// get user's who join this group
    /// - Parameters:
    ///   - groupModel: group model data
    ///   - completion: retrun nil provide array of user's id and success or failure
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
    
}
