//
//  SideMenuView.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 09/07/21.
//

import SwiftUI

//MARK: - Golbal variable
var sideMenuGlobalVariable = ""


//MARK: - View
struct SideMenuView: View {
    
    //MARK: - Properties
    var sidemenuOptions = ["Home","Chat","Group","Logout"]
    var currentUser = UserModel.getCurrentUserFromDefault()
    
    //MARK: - Environment variable
    @Environment(\.moveToOtherView) var moveToOtherView
    
    //MARK: - Body
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    
                    ScrollView(.vertical, showsIndicators: false, content: {
                        VStack(spacing: 20) {
                            
                            Text("\(currentUser?.firstName.prefix(1).uppercased() ?? "F")\(currentUser?.lastName.prefix(1).uppercased() ?? "L")" )
                                .foregroundColor(.white)
                                .font(.title)
                                .bold()
                                .frame(width: ScreenSize.SCREEN_WIDTH*0.35, height: ScreenSize.SCREEN_WIDTH*0.35, alignment: .center)
                                .aspectRatio(contentMode: .fit)
                                .background(Color.random)
                                .clipShape(Circle())
                                .padding(.all, 10)
                            
                            Text("\(currentUser?.firstName ?? "first Name") \(currentUser?.lastName ?? "last name")")
                                .font(.title2)
                                .bold()
                                .frame(width: ScreenSize.SCREEN_WIDTH*0.85)
                            
                            Text("\(currentUser?.email ?? "email")")
                                .font(.title3)
                                .frame(width: ScreenSize.SCREEN_WIDTH*0.85)
                                .padding(.top, -10)
                            
                            
                            LazyVStack(alignment: .center, spacing: 10, pinnedViews: [], content: {
                                ForEach(sidemenuOptions, id: \.self) { item in
                                    HStack{
                                        Text(item)
                                            .font(.title3)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .cornerRadius(6)
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture(perform: {
                                        
                                        switch item {
                                        case "Home":
                                            sideMenuGlobalVariable = item
                                            moveToOtherView?()
                                            print("move to home page")
                                        case "Chat":
                                            sideMenuGlobalVariable = item
                                            moveToOtherView?()
                                            print("move to chat page")
                                        case "Logout":
                                            sideMenuGlobalVariable = item
                                            moveToOtherView?()
                                            print("move to perform logout")
                                        case "Group":
                                            sideMenuGlobalVariable = item
                                            moveToOtherView?()
                                            print("move to perform logout")
                                        default:
                                            break
                                        }
                                        
                                        
                                    })
                                    .padding()
                                    .border(Color("menu"), width:1.5)
                                    
                                }
                            })
                            .frame(width: ScreenSize.SCREEN_WIDTH*0.85)
                            
                            
                            Spacer()
                            
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: geo.size.height, alignment: .center)
                    })
                    
                    
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                
            }
            .navigationBarHidden(true)
            
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

//MARK: - Preview
struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView()
    }
}
