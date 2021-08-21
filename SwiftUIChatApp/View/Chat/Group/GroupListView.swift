//
//  GroupListView.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 16/07/21.
//

import SwiftUI

struct GroupListView: View {
    
    //MARK: - Properties
    @StateObject var groupListVM = GroupListViewModel()
    @StateObject var model = ChatViewModel()
    
    //MARK: - Body
    var body: some View {
        NavigationView {
            
            let drag = DragGesture()
                .onEnded {
                    if $0.translation.width < -100 {
                        withAnimation {
                            groupListVM.showMenu = false
                        }
                    }
                }
            
            
            ZStack(alignment: .leading) {
                ZStack {
                    
                    NavigationLink("", destination: LogInView(loginVM: LoginViewModel()), tag: IdentifiableKeys.NavigationTags.kNavToLogin, selection: $groupListVM.navigation)
                    NavigationLink("", destination: HomeView(homeVM: HomeViewModel()), tag: IdentifiableKeys.NavigationTags.knavToHome, selection: $groupListVM.navigation)
                    NavigationLink("", destination: ChatUserListView(ChatListVM: ChatUserListViewModel()), tag: IdentifiableKeys.NavigationTags.knavToChatUser, selection: $groupListVM.navigation)
                    NavigationLink("", destination: GroupListView(groupListVM: GroupListViewModel()), tag: IdentifiableKeys.NavigationTags.knavToGroupList, selection: $groupListVM.navigation)
                    
                    NavigationLink("", destination: ChatView(model: ChatViewModel(),groupOBJ: groupListVM.selectedGroup, isGroupChat: true), tag: IdentifiableKeys.NavigationTags.knavToChat, selection: $groupListVM.navigation)
                    // to solve navigation Back issue while app on background (14.5 / 14.6)
                    NavigationLink(destination: EmptyView()) {
                        EmptyView()
                    }
                    
                    Group {
                        
                        if !groupListVM.isGridViewActive {
                            
                            VStack {
                                
                                List{
                                    
                                    ForEach(groupListVM.arrOfGroup, id: \.self) { item in
                                        
                                        TableCell(initTitle: "\(item.title.prefix(2).uppercased())", fullName: "\(item.title)",lastMessage: item.lastMessageString, dateString: item.dateString, colorOFCircle: item.avtarColor,activeStatusValue: .hide, buttonClick: {
                                            groupListVM.moveToChat(completion: {
                                                groupListVM.selectedGroup = item
                                            })
                                            
                                        })
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            groupListVM.moveToChat(completion: {
                                                groupListVM.selectedGroup = item
                                            })
                                        }
                                        .contextMenu(ContextMenu(menuItems: {
                                            
                                            if item.admin == UserModel.getCurrentUserID() {
                                                
                                                Button(action: {
                                                    
                                                    model.deleteGroup(groupID: item.groupID) { (sucess) in
                                                        print(sucess)
                                                    }
                                                    
                                                }, label: {
                                                    Label("Delete", systemImage: "trash")
                                                    
                                                })
                                                
                                            }
                                            
                                            
                                        }))
                                        .listRowInsets(.init(top: 0, leading: 0, bottom: 3, trailing: 0))
                                    }
                                    
                                }
                                
                            }
                            
                        } else {
                            
                            ScrollView(.vertical, showsIndicators: false, content: {
                                
                                LazyVGrid(columns: groupListVM.gridLayout, alignment: .center, spacing: 20) {
                                    
                                    ForEach(groupListVM.arrOfGroup, id: \.self) { item in
                                        
                                        NavigationLink(destination: ChatView(model: ChatViewModel(), stroageVM: firebaseStorageViewModel(), groupOBJ: item, isGroupChat: true)) {
                                            
                                            gridViewItem(useName: item.title, initalizeName: "\(item.title.prefix(2).uppercased())", activeStatusValue: .hide)
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                                
                            })
                            .padding(.top, 20)
                            .padding([.leading,.trailing], 10)
                            .animation(.easeInOut)
                            .background(Color("ScrollView"))
                            
                        }
                        
                        
                    }
                    
                    
                    
                }
                .overlay(
                    
                    Button(action: {
                        
                        groupListVM.openSheet = true
                        
                    }, label: {
                        VStack{
                            
                            Image(systemName: "person.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .padding()
                        }
                        .background(Color.random)
                        .clipShape(Circle())
                        .frame(width: 70, height: 70, alignment: .center)
                        
                        
                        
                        
                    })
                    .padding(.trailing,30)
                    .padding(.bottom, 30)
                    , alignment: .bottomTrailing
                )
                .background( groupListVM.showMenu ? Color.black.opacity(0.9) : Color("menu"))
                .disabled( groupListVM.showMenu ? true : false).blur(radius:  groupListVM.showMenu ? 5.0 :0)
                
                if  groupListVM.showMenu {
                    
                    SideMenuView()
                        .frame(width: UIScreen.main.bounds.width*0.9)
                        .transition(.move(edge: .leading))
                        .environment(\.moveToOtherView, groupListVM.moveToOtherView)
                    
                }
                
                
            }
            
            .gesture(drag)
            .environment(\.parentFunction, groupListVM.parentFunction)
            .onAppear(perform: {
                groupListVM.fetchListOfGroup()
            })
            .sheet(isPresented: $groupListVM.openSheet, content: {
                
                GroupChatView(GroupVM: GroupChatViewModel(), isFormGroupChat: false, isFromGroupList: true)
                
            })
            .alert(isPresented: $groupListVM.showAlert, content: {
                Alert(title: Text("Logout"), message: Text("Are you sure you want to logout?"), primaryButton: Alert.Button.cancel(Text("CANCEL"), action: {
                    print("cancel logout")
                }), secondaryButton: Alert.Button.default(Text("OK"), action: {
                    groupListVM.logOut()
                    
                    
                }))
                
            })
            .navigationTitle("Group List")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                                    
                                    Button(action: {
                                        
                                        groupListVM.showMenu.toggle()
                                        
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
                                            
                                            groupListVM.isGridViewActive = false
                                            
                                        }, label: {
                                            Image(systemName: "square.fill.text.grid.1x2")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(Color("menu"))
                                                .frame(width: 30, height: 35, alignment: .center)
                                        })
                                        .padding(.trailing, 20)
                                        
                                        Button(action: {
                                            
                                            groupListVM.isGridViewActive = true
                                            groupListVM.GridSwitch()
                                            
                                        }, label: {
                                            Image(systemName: groupListVM.toolbarIcon)
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
struct GroupListView_Previews: PreviewProvider {
    static var previews: some View {
        GroupListView()
    }
}
