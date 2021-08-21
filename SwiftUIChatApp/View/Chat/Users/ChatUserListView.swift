//
//  ChatUserListView.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 12/07/21.
//

import SwiftUI


//MARK: - View
struct ChatUserListView: View {
    
    //MARK: - Properties
    @StateObject var ChatListVM = ChatUserListViewModel()
    
    //MARK: - Body
    var body: some View {
        NavigationView {
            
            let drag = DragGesture()
                .onEnded {
                    if $0.translation.width < -100 {
                        withAnimation {
                            ChatListVM.showMenu = false
                        }
                    }
                }
            
            
            ZStack(alignment: .leading) {
                ZStack {
                    
                    NavigationLink("", destination: LogInView(loginVM: LoginViewModel()), tag: IdentifiableKeys.NavigationTags.kNavToLogin, selection: $ChatListVM.navigation)
                    NavigationLink("", destination: HomeView(homeVM: HomeViewModel()), tag: IdentifiableKeys.NavigationTags.knavToHome, selection: $ChatListVM.navigation)
                    NavigationLink("", destination: ChatUserListView(ChatListVM: ChatUserListViewModel()), tag: IdentifiableKeys.NavigationTags.knavToChatUser, selection: $ChatListVM.navigation)
                    NavigationLink("", destination: ChatView(model: ChatViewModel(),userObj: ChatListVM.selectedUserModel, isGroupChat: false), tag: IdentifiableKeys.NavigationTags.knavToChat, selection: $ChatListVM.navigation)
                    
                    NavigationLink("", destination: GroupListView(groupListVM: GroupListViewModel()), tag: IdentifiableKeys.NavigationTags.knavToGroupList, selection: $ChatListVM.navigation)
                    
                    // to solve navigation Back issue while app on background (14.5 / 14.6)
                    NavigationLink(destination: EmptyView()) {
                        EmptyView()
                    }
                    
                    
                    Group {
                        
                        if !ChatListVM.isGridViewActive {
                            
                            List{
                                
                                ForEach(ChatListVM.userList, id: \.self) { item in
                                    
                                    TableCell(initTitle: "\(item.firstName.prefix(1).uppercased())\(item.lastName.prefix(1).uppercased())", fullName: "\(item.firstName) \(item.lastName)",lastMessage: item.lastMessageString, dateString: item.dateString,colorOFCircle: item.avtarColor,activeStatusValue: item.isOnline ? .active : .inactive, buttonClick: {
                                        ChatListVM.moveToChat(completion: {
                                            ChatListVM.selectedUserModel = item
                                        })
                                        
                                    })
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        ChatListVM.moveToChat(completion: {
                                            ChatListVM.selectedUserModel = item
                                        })
                                    }
                                    .listRowInsets(.init(top: 0, leading: 0, bottom: 3, trailing: 0))
                                }
                                
                            }
                            
                        } else {
                            
                            ScrollView(.vertical, showsIndicators: false, content: {
                                
                                LazyVGrid(columns: ChatListVM.gridLayout, alignment: .center, spacing: 10, content: {
                                    
                                    ForEach(ChatListVM.userList, id: \.self) { item in
                                        NavigationLink(
                                            destination: ChatView(model: ChatViewModel(),userObj: item, isGroupChat: false)){
                                            
                                            gridViewItem(useName: "\(item.firstName) \(item.lastName)", initalizeName: "\(item.firstName.prefix(1).uppercased())\(item.lastName.prefix(1).uppercased())", activeStatusValue: item.isOnline ? .active : .inactive)
                                            
                                            
                                        }
                                    }
                                    
                                })
                                
                            })
                            .padding(.top, 20)
                            .padding([.leading,.trailing], 10)
                            .background(Color("ScrollView"))
                            .animation(.easeInOut)
                            
                        }
                        
                        
                        
                    }
                    
                }
                .background( ChatListVM.showMenu ? Color.black.opacity(0.9) : Color("ScrollView"))
                //                        .offset(x: self.showMenu ? UIScreen.main.bounds.width*0.9 : 0)
                .disabled( ChatListVM.showMenu ? true : false).blur(radius:  ChatListVM.showMenu ? 5.0 :0)
                
                
                if  ChatListVM.showMenu {
                    
                    SideMenuView()
                        .frame(width: UIScreen.main.bounds.width*0.9)
                        .transition(.move(edge: .leading))
                        .environment(\.moveToOtherView, ChatListVM.moveToOtherView)
                    
                }
                
                
            }
            
            .gesture(drag)
            .environment(\.parentFunction, ChatListVM.parentFunction)
            .onAppear(perform: {
                ChatListVM.getUsers()
            })
            .alert(isPresented: $ChatListVM.showAlert, content: {
                
                Alert(title: Text("Logout"), message: Text("Are you sure you want to logout?"), primaryButton: Alert.Button.cancel(Text("CANCEL"), action: {
                    print("cancel logout")
                }), secondaryButton: Alert.Button.default(Text("OK"), action: {
                    
                    
                    ChatListVM.logOut()
                    
                    
                }))
                
            })
            .navigationTitle("Chat List")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                                    
                                    Button(action: {
                                        
                                        ChatListVM.showMenu.toggle()
                                        
                                    }, label: {
                                        Image(systemName: "slider.horizontal.3") // text.alignleft // menubar.rectangle
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(Color("menu"))
                                            .frame(width: 30, height: 35, alignment: .center)
                                    })
                                ,trailing:
                                    
                                    HStack {
                                        Button(action: {
                                            
                                            ChatListVM.isGridViewActive = false
                                            
                                        }, label: {
                                            Image(systemName: "square.fill.text.grid.1x2")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(Color("menu"))
                                                .frame(width: 30, height: 35, alignment: .center)
                                        })
                                        .padding(.trailing, 20)
                                        
                                        Button(action: {
                                            
                                            ChatListVM.isGridViewActive = true
                                            ChatListVM.GridSwitch()
                                            
                                        }, label: {
                                            Image(systemName: ChatListVM.toolbarIcon)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(Color("menu"))
                                                .frame(width: 30, height: 35, alignment: .center)
                                        })
                                    }
            )
            
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


//MARK: - Preview
struct ChatUserListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatUserListView()
    }
}
