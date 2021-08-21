//
//  ForwardMessageView.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 27/07/21.
//

import SwiftUI

struct ForwardMessageView: View {
    
    //MARK: - Properties
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var forwardVM = ForwardLIstViewModel()
    @State var userModel = UserModel()
    @State var groupModels = GroupModel()
    var selectedMessage: MessageModel
    var chatUsersID:String
    var isFromGroup:Bool
    
    //MARK: - Body
    var body: some View {
        ZStack {
            VStack {
                
                
                if forwardVM.arrGorup.isEmpty && forwardVM.arrChatUsers.isEmpty && forwardVM.arrNotChatUsers.isEmpty {
                    
                    Spacer()
                    
                    Text("No Users Found")
                        .bold()
                        .font(.title)
                    Spacer()
                    
                } else {
                    
                    List {
                        
                        if !forwardVM.arrChatUsers.isEmpty {
                            
                            Section(header: Text("Users")) {

                                ForEach(forwardVM.arrChatUsers,id: \.self) { item in
                                    
                                    GroupUserCell(initTitle: "\(item.firstName.prefix(1).uppercased())\(item.lastName.prefix(1).uppercased())", fullName: "\(item.firstName) \(item.lastName)", colorOFCircle: Color.random, buttonClick: {
                                        
                                        userModel = item
                                        
                                    }, currentSelectedUser: $userModel, currentSelectedGroup: $groupModels)
                                    
                                }
                                
                            }
                            
                        }
                        
                        if !forwardVM.arrGorup.isEmpty {
                            
                            Section(header: Text("Groups")) {
                               
                                ForEach(forwardVM.arrGorup,id: \.self) { item in
                                    
                                    GroupUserCell(initTitle: item.title.prefix(2).uppercased(), fullName: item.title, colorOFCircle: Color.random, buttonClick: {
                                        
                                        groupModels = item
                                        
                                    }, currentSelectedUser: $userModel, currentSelectedGroup: $groupModels)
                                }
                                
                            }
                        }
                        
                        if !forwardVM.arrNotChatUsers.isEmpty {
                            
                            Section(header: Text("Other Users")) {
                                
                                ForEach(forwardVM.arrNotChatUsers,id: \.self) { item in
                                    
                                    GroupUserCell(initTitle: "\(item.firstName.prefix(1).uppercased())\(item.lastName.prefix(1).uppercased())", fullName: "\(item.firstName) \(item.lastName)", colorOFCircle: Color.random, buttonClick: {
                                        
                                        userModel = item
                                        
                                    }, currentSelectedUser: $userModel, currentSelectedGroup: $groupModels)
                                    
                                }
                                
                            }
                            
                        }
                        
                        
                    }
                    .padding([.bottom], 10)
                    
                    Button(action: {
                        
                        // send message to all selected users
                        forwardVM.forwradMessage(message: selectedMessage, completion: {
                            
                            presentationMode.wrappedValue.dismiss()
                            
                        })
                        
                    }, label: {
                        Text("Forward".uppercased())
                            .foregroundColor(.white)
                            .font(.title2)
                            .frame(width: ScreenSize.SCREEN_WIDTH*0.85, height: 60, alignment: .center)
                            .background(Color.random.opacity(0.95))
                            .cornerRadius(20)
                    })
                    .padding([.bottom,.top], 20)
                    
                }
                
            }//: inner VStack
            .progressHUD(isShowing: $forwardVM.showLoader)
            .onAppear(perform: {
                

                if isFromGroup {
                    
                    forwardVM.getAllGroupWhoIAmIn(selectedGroup: chatUsersID) { (sucess) in
                        print("Fetch all groups = \(sucess)")
                        
                        forwardVM.getAllUserWhoChatWithMe { (success) in
                            print("Fetch all users = \(success)")
                            
                            forwardVM.getAllUsersNotChatWIthMe { (resultValue) in
                                print("Fetch other users = \(resultValue)")
                                print("message Data = \(selectedMessage.documentId)")
                            }
                        }
                        
                    }
                    
                    
                } else {
                    forwardVM.getAllGroupWhoIAmIn { (sucess) in
                        
                        print("Fetch all groups = \(sucess)")
                        
                        forwardVM.getAllUserWhoChatWithMe(alreadyShared: chatUsersID) { (success) in
                            print("Fetch all users = \(success)")
                            
                            forwardVM.getAllUsersNotChatWIthMe(completion: { (resultValue) in
                                
                                print("Fetch other users = \(resultValue)")
                                print("message Data = \(selectedMessage.documentId)")
                                
                            })
                            
                        }
                        
                    }
                }
               
                
            })
            .alert(isPresented: $forwardVM.showAlert) { () -> Alert in
                
                let alertObj = Alert(title: Text(""), message: Text(forwardVM.errorMessage), dismissButton: Alert.Button.default(Text("OK")))
                return alertObj
                
            }
        }//: ZStack
    }
}

//MARK: - Preview
struct ForwardMessageView_Previews: PreviewProvider {
    static var previews: some View {
        ForwardMessageView(selectedMessage: MessageModel(), chatUsersID: "", isFromGroup: false)
    }
}
