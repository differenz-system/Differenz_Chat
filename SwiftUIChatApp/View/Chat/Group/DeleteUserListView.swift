//
//  DeleteUserListView.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 20/07/21.
//

import SwiftUI

struct DeleteUserListView: View {
    
    //MARK: - Properpies
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var groupModel:GroupModel?
    @StateObject var model = DeleteUserViewModel()
    @State var userModel = UserModel()
    @State var groupModels = GroupModel()
    
    
    //MARK: - Body
    var body: some View {
        ZStack {
            
            Group {
                
                if model.arrUsers.isEmpty {
                    
                    VStack {
                        
                        Spacer()
                        
                        Text("No users found")
                            .bold()
                            .font(.title)
                        
                        Spacer()
                        
                    }
                    
                    
                } else {
                    
                    VStack {
                        
                        List {
                            ForEach(model.arrUsers,id: \.self) { item in
                                
                                GroupUserCell(initTitle: "\(item.firstName.prefix(1).uppercased())\(item.lastName.prefix(1).uppercased())", fullName: "\(item.firstName) \(item.lastName)", colorOFCircle: Color.random, buttonClick: {
                                    
                                    userModel = item
          
                                }, currentSelectedUser: $userModel, currentSelectedGroup: $groupModels)
                                
                            }
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 3, trailing: 0))
                            }//: List
                        
                        Button(action: {
                            
                            guard let groupModel = groupModel else {
                                return
                            }
                            
                            model.addButtonAction(groupID: groupModel.groupID) {
                                SwiftUIChatApp.sharedInstance.updatedGroupData = model.updatedGroup
                                let dict = [kGroupID: model.updatedGroup.groupID,kAdmin:model.updatedGroup.admin,kTitle:model.updatedGroup.title,kCreatedTimeStamp:model.updatedGroup.createdTimeStamp,kUserIds:model.updatedGroup.userIds] as [String : Any]

                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NSNotification.Name.RawValue("update usermodel")), object: dict)
                                mode.wrappedValue.dismiss()
                            }
                            
                            
                        }, label: {
                            Text("remove".uppercased())
                                .foregroundColor(.white)
                                .font(.title2)
                                .frame(width: ScreenSize.SCREEN_WIDTH*0.85, height: 60, alignment: .center)
                                .background(Color.random.opacity(0.95))
                                .cornerRadius(20)
                        })
                        .padding([.bottom,.top], 20)
  
                    }
                    
                }
                
                
                
            }
            .onAppear(perform: {
                model.getUsers(groupModel: groupModel)
            })
            .alert(isPresented: $model.showingError, content: {
                
                Alert(title: Text(""), message: Text(model.errorMessage), dismissButton: Alert.Button.default(Text("OK")))
                
            })
            
            
           
        }.hideNavigationBar()
    }
}

//MARK: - Preview
struct DeleteUserListView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteUserListView()
    }
}
