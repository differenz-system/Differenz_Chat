//
//  GroupUserList.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 20/07/21.
//

import SwiftUI

struct GroupUserList: View {
    
    //MARK: - Properties
    @StateObject var groupListVM = GroupUserListViewModel()
    var groupModel:GroupModel?
    @State var openChat = false
    
    var body: some View {
        ZStack {
            
            Group {
                
                if groupListVM.arrusers.isEmpty {
                    
                    VStack {
                        
                        Spacer()
                        
                        Text("No User found")
                            .bold()
                            .font(.title)
                        
                        Spacer()
                        
                        
                    }
                    
                } else {
                    
                    VStack {
                        List{
                            
                            ForEach(groupListVM.arrusers, id: \.self) { item in
                                
                                TableCell(initTitle: "\(item.firstName.prefix(1).uppercased())\(item.lastName.prefix(1).uppercased())", fullName: "\(item.firstName) \(item.lastName)", lastMessage: "", dateString: "", colorOFCircle: item.avtarColor,activeStatusValue:item.isOnline ? .active : .inactive, buttonClick: {
                                    
                                    groupListVM.moveToChat(userModel: item) {
                                        self.openChat.toggle()
                                    }
                                    
                                })
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    groupListVM.moveToChat(userModel: item) {
                                        self.openChat.toggle()
                                    }
                                }
                                
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 3, trailing: 0))
                            }
                            
                        }
                        
                    }
                    
                }
                
                
                
            }
            .onAppear(perform: {
                groupListVM.getUsers(groupModel: groupModel)
            })
            .fullScreenCover(isPresented: $openChat, content: {
                ChatView(model: ChatViewModel(),userObj: groupListVM.selectedUser, isGroupChat: false)
            })
            
        }
    }
}

struct GroupUserList_Previews: PreviewProvider {
    static var previews: some View {
        GroupUserList()
    }
}
