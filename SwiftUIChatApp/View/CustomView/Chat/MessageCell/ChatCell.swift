//
//  ChatCell.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 13/07/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatCell: View {
    
    //MARK: - Properties
    var position: BubblePosition
    var color : Color
    var chatText:String
    var TimeStamp:String
    var messageType:Int
    var imageURL:String
    var copyText: () -> Void
    var openImage: () -> Void
    var forwardMessage: () -> Void
    var deleteMessage: () -> Void
   
    
    
    
    //MARK: - Body
    var body: some View {
    
        Menu {
            
            if messageType == 1 || messageType == 3 {
                
                Button(action: {
                    
                  copyText()
                    
                }) {
                    Text("copy")
                    Image(systemName: "doc.on.doc")
                    
                }
                
            }
            
            
            if messageType == 2 || messageType == 3 {
                
                Button(action: {
                    
                   openImage()
                    
                }) {
                    Text("open")
                    Image(systemName: "doc.plaintext")
                    
                }
                
            }
            
            Button(action: {
                
                forwardMessage()
                
            }) {
                Text("forward")
                Image(systemName: "arrowshape.turn.up.forward")
                
            }
            
            Divider()
            
            if position == .right {
                
                Button(action: {
                    
                    deleteMessage()
                    
                }) {
                    Text("delete")
                        .foregroundColor(.red)
                    Image(systemName: "minus.circle")
                        .foregroundColor(.red)
                    
                }
                
            }
            
            
        } label: {
            HStack(alignment: .center, spacing: 0, content: {
                VStack(alignment: position == .left ? .leading : .trailing ) {
                    
                    if messageType == 1 {
                        Text(chatText)
                            .padding(.bottom, 3)
                    } else if messageType == 2 {
                        AnimatedImage(url: URL(string: imageURL))
                            .resizable()
                            .indicator(.activity)
                            .cornerRadius(7)
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .padding(.bottom, 3)
                    } else if messageType == 3 {
                        
                        AnimatedImage(url: URL(string: imageURL))
                            .resizable()
                            .indicator(.activity)
                            .cornerRadius(7)
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .padding(.bottom, 3)
                        Text(chatText)
                            .padding(.bottom, 3)
                        
                    }
                    
                    HStack{
                        
                        Text(TimeStamp)
                            .lineLimit(1)
                        
                    }
                }
                .padding(.all, 15)
                .foregroundColor(Color.white)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    Image(systemName: "arrowtriangle.left.fill")
                        .foregroundColor(color)
                        .rotationEffect(Angle(degrees: position == .left ? -50 : -130))
                        .offset(x: position == .left ? -5 : 5)
                    ,alignment: position == .left ? .bottomLeading : .bottomTrailing)
            })
            .padding(position == .left ? .leading : .trailing , 15)
            .padding(position == .right ? .leading : .trailing , 60)
            .frame(width: UIScreen.main.bounds.width, alignment: position == .left ? .leading : .trailing)
        }
        .onTapGesture {}
        
        
        
        
        
        
    }
}

//MARK: - Preview
struct ChatCell_Previews: PreviewProvider {
    static var previews: some View {
        
        ChatCell(position: BubblePosition.left, color: Color.blue, chatText: "hncdfsvkkljbfdvjkl jkdfsbvjk  jkdfsbvjkbdlsbjv jkdsfbvjkd", TimeStamp: "bshjvxvx", messageType: 3, imageURL: "www.google.com", copyText: {
            
        }, openImage: {
            
        }, forwardMessage: {
            
        }, deleteMessage: {
            
        })
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
