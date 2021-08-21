//
//  GroupUserCell.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 15/07/21.
//

import SwiftUI

struct GroupUserCell: View {
    
    //MARK: - Properties
    var initTitle:String
    var fullName:String
    var colorOFCircle:Color
    @State var isSelected = false
    var buttonClick: () -> Void
    @Binding var currentSelectedUser:UserModel
    @Binding var currentSelectedGroup:GroupModel
    @StateObject var groupVM = GroupChatViewModel()
    
    
    //MARK: - Body
    var body: some View {
        VStack {
            HStack {
                Text(initTitle)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width*0.12, height: UIScreen.main.bounds.width*0.12, alignment: .center)
                    .aspectRatio(contentMode: .fit)
                    .background(colorOFCircle)
                    .clipShape(Circle())
                
                VStack{
                    Text(fullName)
                        .font(.title3)
                        .lineLimit(1)
                }
                Spacer()
                
                if isSelected {
                    
                    Button(action: {
                        
                        buttonClick()
                        isSelected = false
                        currentSelectedUser.isSelected = false
                        currentSelectedGroup.isSelected = false
                        
                        
                    }, label: {
                        
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30, alignment: .center)
                        
                    })
                    .buttonStyle(PlainButtonStyle())
                    
                } else {
                    Button(action: {
                        
                        buttonClick()
                        isSelected = true
                        currentSelectedUser.isSelected = true
                        currentSelectedGroup.isSelected = true
                        
                        
                    }, label: {
                        
                        Image(systemName: "circle") // circle or  checkmark.circle
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30, alignment: .center)
                        
                    })
                    .buttonStyle(PlainButtonStyle())
                    
                }
                
            }
            .padding()
        }
    }
}

//MARK: - Preview
struct GroupUserCell_Previews: PreviewProvider {
    static var previews: some View {
        
        let userDIct:[String:Any] = ["":""]
        
        GroupUserCell(initTitle: "FN", fullName: "full name", colorOFCircle: Color.random, buttonClick: {}, currentSelectedUser: .constant(UserModel(dictionary: userDIct)), currentSelectedGroup: .constant(GroupModel()))
            .previewLayout(.sizeThatFits)
        
    }
}
