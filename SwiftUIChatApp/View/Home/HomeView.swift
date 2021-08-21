//
//  HomeView.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 09/07/21.
//

import SwiftUI



//MARK: - Custom Environment
struct ParentFunctionKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var parentFunction: (() -> Void)? {
        get { self[ParentFunctionKey.self] }
        set { self[ParentFunctionKey.self] = newValue }
    }
    
    var moveToOtherView: (()-> Void)? {
        get { self[ParentFunctionKey.self] }
        set { self[ParentFunctionKey.self] = newValue }
    }
    
    
}

struct HomeView: View {
    
    //MARK: - Properties
    @StateObject var homeVM = HomeViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    
    //MARK: - Body
    var body: some View {
        NavigationView {
            
            let drag = DragGesture()
                .onEnded {
                    if $0.translation.width < -100 {
                        withAnimation {
                            homeVM.showMenu = false
                        }
                    }
                }
            
            
            ZStack(alignment: .leading) {
                ZStack {
                    
                    NavigationLink("", destination: LogInView(loginVM: LoginViewModel()), tag: IdentifiableKeys.NavigationTags.kNavToLogin, selection: $homeVM.navigation)
                    NavigationLink("", destination: HomeView(homeVM: HomeViewModel()), tag: IdentifiableKeys.NavigationTags.knavToHome, selection: $homeVM.navigation)
                    NavigationLink("", destination: ChatUserListView(ChatListVM: ChatUserListViewModel()), tag: IdentifiableKeys.NavigationTags.knavToChatUser, selection: $homeVM.navigation)
                    NavigationLink("", destination: ChatView(model: ChatViewModel(),userObj: homeVM.selectedUserModel, isGroupChat: false), tag: IdentifiableKeys.NavigationTags.knavToChat, selection: $homeVM.navigation)
                    NavigationLink("", destination: GroupListView(groupListVM: GroupListViewModel()), tag: IdentifiableKeys.NavigationTags.knavToGroupList, selection: $homeVM.navigation)
                    NavigationLink("", destination: ChatView(model: ChatViewModel(), groupOBJ: homeVM.selectedGroupModel, isGroupChat: true), tag: IdentifiableKeys.NavigationTags.knavToGroupChat, selection: $homeVM.navigation)
                    // to solve navigation Back issue while app on background (14.5 / 14.6)
                    NavigationLink(destination: EmptyView()) {
                        EmptyView()
                    }
                    
                    VStack {
                        
                        Group {
                            
                            VStack {
                                
                                if !homeVM.isGridViewActive {
                                    
                                    List{
                                        
                                        if !homeVM.userList.isEmpty {
                                            
                                            Section(header: Text("Chat")) {
                                                
                                                ForEach(homeVM.userList, id: \.self) { item in
                                                    
                                                    TableCell(initTitle: "\(item.firstName.prefix(1).uppercased())\(item.lastName.prefix(1).uppercased())", fullName: "\(item.firstName) \(item.lastName)", lastMessage: item.lastMessageString, dateString: item.dateString, colorOFCircle: item.avtarColor,activeStatusValue: item.isOnline ? .active : .inactive, buttonClick: {
                                                        
                                                        homeVM.moveToChat(isGroup: false) {
                                                            homeVM.selectedUserModel = item
                                                        }
                                                        
                                                        
                                                        
                                                    })
                                                    .contentShape(Rectangle())
                                                    .onTapGesture {
                                                        homeVM.moveToChat(isGroup: false) {
                                                            homeVM.selectedUserModel = item
                                                        }
                                                    }
                                                    .listRowInsets(.init(top: 0, leading: 0, bottom: 3, trailing: 0))
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                        if !homeVM.arrOfGroup.isEmpty {
                                            
                                            Section(header: Text("Groups")) {
                                                
                                                ForEach(homeVM.arrOfGroup, id: \.self) { item in
                                                    
                                                    TableCell(initTitle: "\(item.title.prefix(2).uppercased())", fullName: "\(item.title)",lastMessage: item.lastMessageString, dateString: item.dateString, colorOFCircle: item.avtarColor,activeStatusValue: .hide, buttonClick: {
                                                        
                                                        homeVM.moveToChat(isGroup: true) {
                                                            homeVM.selectedGroupModel = item
                                                        }
                                                        
                                                    })
                                                    .contentShape(Rectangle())
                                                    .onTapGesture {
                                                        homeVM.moveToChat(isGroup: true) {
                                                            homeVM.selectedGroupModel = item
                                                        }
                                                    }
                                                    .listRowInsets(.init(top: 0, leading: 0, bottom: 3, trailing: 0))
                                                    
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                        if !homeVM.otherUsers.isEmpty {
                                            
                                            Section(header: Text(homeVM.userList.isEmpty ? "Users" : "Other Users")) {
                                                ForEach(homeVM.otherUsers, id: \.self) { item in
                                                    
                                                    TableCell(initTitle: "\(item.firstName.prefix(1).uppercased())\(item.lastName.prefix(1).uppercased())", fullName: "\(item.firstName) \(item.lastName)", lastMessage: item.lastMessageString, dateString: "", colorOFCircle: item.avtarColor,activeStatusValue: .hide, buttonClick: {
                                                        
                                                        homeVM.moveToChat(isGroup: false) {
                                                            homeVM.selectedUserModel = item
                                                        }
                                                        
                                                    })
                                                    .contentShape(Rectangle())
                                                    .onTapGesture {
                                                        homeVM.moveToChat(isGroup: false) {
                                                            homeVM.selectedUserModel = item
                                                        }
                                                    }
                                                    .listRowInsets(.init(top: 0, leading: 0, bottom: 3, trailing: 0))
                                                }
                                            }
                                            
                                        }
                                        
                                        
                                        
                                        
                                    }
                                    
                                    
                                } else {
                                    
                                    ScrollView(.vertical, showsIndicators: false, content: {
                                        
                                        LazyVGrid(columns: homeVM.gridLayout, alignment: .center, spacing: 10, content: {
                                            
                                            if !homeVM.userList.isEmpty {
                                                
                                                Section(header:
                                                            
                                                            HStack {
                                                                Text("Chat".uppercased())
                                                                    .font(.title)
                                                                    .fontWeight(.bold)
                                                                
                                                                
                                                                Spacer()
                                                            }
                                                        
                                                ) {
                                                    
                                                    ForEach(homeVM.userList, id: \.self) { item in
                                                        NavigationLink(
                                                            destination: ChatView(model: ChatViewModel(),userObj: item, isGroupChat: false)){
                                                            
                                                            gridViewItem(useName: "\(item.firstName) \(item.lastName)", initalizeName: "\(item.firstName.prefix(1).uppercased())\(item.lastName.prefix(1).uppercased())", activeStatusValue: item.isOnline ? .active : .inactive)
                                                            
                                                            
                                                        }
                                                    }
                                                }
                                                
                                            }
                                            
                                            if !homeVM.arrOfGroup.isEmpty {
                                                
                                                Section(header:
                                                            
                                                            HStack {
                                                                Text("Group".uppercased())
                                                                    .font(.title)
                                                                    .fontWeight(.bold)
                                                                Spacer()
                                                            }
                                                        
                                                        
                                                ) {
                                                    
                                                    ForEach(homeVM.arrOfGroup, id: \.self) { item in
                                                        
                                                        NavigationLink(destination: ChatView(model: ChatViewModel(), groupOBJ: item ,isGroupChat: true)) {
                                                            
                                                            gridViewItem(useName: item.title, initalizeName: item.title.prefix(2).uppercased(), activeStatusValue: .hide)
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                            if !homeVM.otherUsers.isEmpty {
                                                
                                                Section(header:
                                                            
                                                            HStack {
                                                                Text(homeVM.userList.isEmpty ? "Users".uppercased() : "Other Users".uppercased())
                                                                    .font(.title)
                                                                    .fontWeight(.bold)
                                                                
                                                                Spacer()
                                                            }
                                                        
                                                ) {
                                                    ForEach(homeVM.otherUsers, id: \.self) { item in
                                                        NavigationLink(
                                                            destination: ChatView(model: ChatViewModel(),userObj: item, isGroupChat: false)){
                                                            
                                                            gridViewItem(useName: "\(item.firstName) \(item.lastName)", initalizeName: "\(item.firstName.prefix(1).uppercased())\(item.lastName.prefix(1).uppercased())", activeStatusValue: .hide)
                                                            
                                                            
                                                        }
                                                    }
                                                }
                                                
                                            }
                                            
                                            
                                        })
                                        
                                    })
                                    .padding(.top, 20)
                                    .padding([.leading,.trailing], 10)
                                    .animation(.easeInOut)
                                    .background(Color("ScrollView"))
                                }
                            }
                            
                        }
                        
                    }
                    
                    
                }
                .background( homeVM.showMenu ? Color.black.opacity(0.9) : Color("ScrollView"))
                .disabled( homeVM.showMenu ? true : false).blur(radius:  homeVM.showMenu ? 5.0 :0)
                
                
                if  homeVM.showMenu {
                    
                    SideMenuView()
                        .frame(width: UIScreen.main.bounds.width*0.9)
                        .transition(.move(edge: .leading))
                        .environment(\.moveToOtherView, homeVM.moveToOtherView)
                    
                }
                
                
            }
            .gesture(drag)
            .environment(\.parentFunction, homeVM.parentFunction)
            .onAppear(perform: {
                
                homeVM.getChatUsers {
                    homeVM.getOtherUsers {
                        
                        homeVM.fetchListOfGroup {
                            
                            
                        }
                    }
                }
                
            })
            .onChange(of: scenePhase, perform: { value in
                
                if value == .active {
                    
                    homeVM.changeActivityStatus(makeUserInActive: false) {
                        
                    }
                    
                } else if value == .inactive {
                    
                    homeVM.changeActivityStatus(makeUserInActive: true) {
                        
                    }
                    
                } else if value == .background {
                    
                    homeVM.changeActivityStatus(makeUserInActive: true) {
                        
                    }
                    
                }
                
            })
            .alert(isPresented: $homeVM.showAlert, content: {
                
                Alert(title: Text("Logout"), message: Text("Are you sure you want to logout?"), primaryButton: Alert.Button.cancel(Text("CANCEL"), action: {
                    print("cancel logout")
                }), secondaryButton: Alert.Button.default(Text("OK"), action: {
                    
                    homeVM.logOut()
                    
                    
                }))
                
            })
            .navigationTitle("User List")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                                    
                                    Button(action: {
                                        
                                        homeVM.showMenu.toggle()
                                        
                                    }, label: {
                                        Image(systemName: "slider.horizontal.3")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(Color("menu"))
                                            .frame(width: 30, height: 35, alignment: .center)
                                    })
                                ,trailing:
                                    
                                    HStack {
                                        Button(action: {
                                            
                                            homeVM.isGridViewActive = false
                                            
                                        }, label: {
                                            Image(systemName: "square.fill.text.grid.1x2")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(Color("menu"))
                                                .frame(width: 30, height: 35, alignment: .center)
                                        })
                                        .padding(.trailing, 20)
                                        
                                        Button(action: {
                                            
                                            homeVM.isGridViewActive = true
                                            homeVM.GridSwitch()
                                            
                                        }, label: {
                                            Image(systemName: homeVM.toolbarIcon)
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
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
