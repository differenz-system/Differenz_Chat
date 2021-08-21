//
//  ChatNavBar.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 20/07/21.
//

import SwiftUI

//MARK: - active status
/// show if user online or not
enum activeStatus {
    case active
    case inactive
    case hide
}

//MARK: - ChatNavBar
struct ChatNavBar: View {
    
    //MARK: - Properties
    
    var circleText:String
    var headlineText:String
    var subHeadlineText:String
    var isFromGorupList:Bool
    var isHideADDButton:Bool
    var activeStatusValue: activeStatus
    var backButtonAction:() -> Void
    var addButtonAction:() -> Void
    var deleteButtonAction:() -> Void
    var showUserListAction:() -> Void
    
    //MARK: - Body
    var body: some View {
        HStack(alignment: .center, spacing: nil, content: {
            
            Button(action: {
                
                backButtonAction()
                
            }, label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color("menu"))
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35, alignment: .center)
            })
            .buttonStyle(PlainButtonStyle())
            .padding(.leading, 5)
            
            
            
            HStack {
                
                Text(circleText)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width*0.1, height: UIScreen.main.bounds.width*0.1, alignment: .center)
                    .aspectRatio(contentMode: .fit)
                    .background(Color.random)
                    .clipShape(Circle())
                    .overlay(
                        
                        Circle()
                            .foregroundColor(self.activeStatusValue == activeStatus.hide ? .clear : self.activeStatusValue == activeStatus.active ? .green : .red)
                            .frame(width: 10, height: 10, alignment: .center)
                        ,alignment: .bottomTrailing
                        
                    )
                
                VStack(alignment: .leading){
                    Text(headlineText)
                        .font(.headline)
                        .font(.system(size: 20))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                    if isFromGorupList {
                        Text("by: \(subHeadlineText)")
                            .font(.subheadline)
                            .font(.system(size: 16))
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding([.leading,.trailing], 10)
            }
            Spacer()
            
            if !isHideADDButton {
                
                Button(action: {
                    
                    addButtonAction()
                    
                }, label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color("menu"))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35, alignment: .center)
                })
                .buttonStyle(PlainButtonStyle())
                
            }
            
            if isFromGorupList {
                Button(action: {
                    
                    deleteButtonAction()
                    
                }, label: {
                    Image(systemName: "xmark.bin")
                        .foregroundColor(Color("menu"))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35, alignment: .center)
                })
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    
                    showUserListAction()
                    
                }, label: {
                    Image(systemName: "person")
                        .foregroundColor(Color("menu"))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35, alignment: .center)
                })
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 5)
                
            }
            
        })
        .padding(.bottom, 10)
        .overlay(Divider().background(Color.gray.frame(height: 0.5)), alignment: .bottom)
    }
}

//MARK: - Preview
struct ChatNavBar_Previews: PreviewProvider {
    static var previews: some View {
        ChatNavBar(circleText: "TS", headlineText: "Text Group", subHeadlineText: "jeet rajput", isFromGorupList: true, isHideADDButton: false, activeStatusValue: .hide, backButtonAction: {
            
        }, addButtonAction: {
            
        }, deleteButtonAction: {
            
        }, showUserListAction: {
            
        })
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
