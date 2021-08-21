//
//  GroupChatView.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 15/07/21.
//

import SwiftUI

struct GroupChatView: View {
    
    //MARK: - Properties
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var GroupVM = GroupChatViewModel()
    var selectedGroup:GroupModel?
    var selectedUser:UserModel?
    
    var isFormGroupChat:Bool
    var isFromGroupList:Bool
    @State var userModel = UserModel()
    @State var groupModels = GroupModel()
    
    
    //MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                
                NavigationLink("", destination: ChatView(model: ChatViewModel(),groupOBJ: !isFormGroupChat ? GroupVM.createdGroup : selectedGroup, isGroupChat: true), tag: IdentifiableKeys.NavigationTags.knavToGroupChat, selection: $GroupVM.navigation)
                
                
                
                Group {
                    
                    if GroupVM.arrOfUsers.isEmpty {
                        
                        VStack {
                            
                            Spacer()
                            
                            Text("Users not found")
                                .bold()
                                .font(.title)
                            
                            Spacer()
                            
                            
                        }
                        
                    } else {
                        
                        VStack {
                            
                            if !isFormGroupChat {
                                
                                TextField("Enter Group Name", text: $GroupVM.GroupNameTextField)
                                    .padding(.leading, 10)
                                    .frame(width: ScreenSize.SCREEN_WIDTH*0.85, height: 60, alignment: .center)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color("menu"), lineWidth: 3)
                                    )
                                    .cornerRadius(6)
                                    .padding([.top], 30)
                                
                            }
                            
                            List {
                                ForEach(GroupVM.arrOfUsers,id: \.self) { item in
                                    
                                    GroupUserCell(initTitle: "\(item.firstName.prefix(1).uppercased())\(item.lastName.prefix(1).uppercased())", fullName: "\(item.firstName) \(item.lastName)", colorOFCircle: Color.random, buttonClick: {
                                        
                                        userModel = item
                                        
                                    }, currentSelectedUser: $userModel, currentSelectedGroup: $groupModels)
                                    
                                }
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 3, trailing: 0))
                            }
                            
                            Button(action: {
                                
                                if !isFormGroupChat {
                                    
                                    if !isFromGroupList {
                                        
                                        guard let userobj = selectedUser else {
                                            return
                                        }
                                        
                                        
                                        
                                        GroupVM.addButonOfOneToOneChat(selectedUser: userobj, completion: {
                                            
                                            GroupVM.openSheet = true
                                            
                                        })
                                        
                                    } else {
                                        
                                        GroupVM.addButtonForGroupLIstView {
                                            GroupVM.openSheet = true
                                        }
                                        
                                    }
                                    
                                } else {
                                    
                                    guard let groupModel = selectedGroup else {
                                        return
                                    }
                                    
                                    GroupVM.addButtonOFGroupChat(GroupID: groupModel.groupID, arrayOfUsers: groupModel.userIds) {
                                        
                                        
                                        
                                        SwiftUIChatApp.sharedInstance.updatedGroupData = GroupVM.updatedGroup
                                        let dict = [kGroupID: GroupVM.updatedGroup.groupID,kAdmin:GroupVM.updatedGroup.admin,kTitle:GroupVM.updatedGroup.title,kCreatedTimeStamp:GroupVM.updatedGroup.createdTimeStamp,kUserIds:GroupVM.updatedGroup.userIds] as [String : Any]
                                        
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NSNotification.Name.RawValue("update usermodel")), object: dict)
                                        
                                        self.mode.wrappedValue.dismiss()
                                        
                                    }
                                    
                                }
                                
                                
                            }, label: {
                                Text("ADD")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .frame(width: ScreenSize.SCREEN_WIDTH*0.85, height: 60, alignment: .center)
                                    .background(Color.random.opacity(0.95))
                                    .cornerRadius(20)
                            })
                            .padding([.bottom,.top], 20)
                            
                        }//: Vsatck
                        
                    }
                    
                    
                    
                    
                    
                }
                .fullScreenCover(isPresented: $GroupVM.openSheet, content: {
                    
                    
                    GroupListView(groupListVM: GroupListViewModel())
                    
                    
                })
                .onAppear(perform: {
                    
                    if !isFormGroupChat {
                        
                        
                        if !isFromGroupList {
                            
                            guard let userobj = selectedUser else {
                                return
                            }
                            
                            GroupVM.getUsersList(selectedUserID: userobj.uID)
                            
                        } else {
                            
                            GroupVM.getUserListWithOutSelecetedUser()
                        }
                        
                        
                        
                    } else {
                        
                        guard let groupModel = selectedGroup else {
                            return
                        }
                        
                        GroupVM.getNotGroupUsersList(addedUserList: groupModel.userIds, completion: {
                            
                        })
                        
                    }
                    
                    
                })
                .alert(isPresented: $GroupVM.showingError, content: {
                    Alert(title: Text(""), message: Text(GroupVM.errorMessage), dismissButton: Alert.Button.default(Text("OK")))
                })
                .hideNavigationBar()
            }
        }
    }
}


//MARK: - Preview
struct GroupChatView_Previews: PreviewProvider {
    static var previews: some View {
        GroupChatView(isFormGroupChat: false, isFromGroupList: false)
            .previewDevice("iPhone 11")
    }
}
