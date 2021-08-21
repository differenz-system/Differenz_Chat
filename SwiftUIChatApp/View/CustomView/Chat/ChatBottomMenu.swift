//
//  ChatBottomMenu.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 20/07/21.
//

import SwiftUI

struct ChatBottomMenu: View {
    
    //MARK: - Properties
    @StateObject var model = ChatViewModel()
    @Binding var inputImage:Image
    @Binding var showImageBox: Bool
    @Binding var messageText:String
    var shareButtonAction:() -> Void
    var cameraAction:() -> Void
    var gallaryAction:() -> Void
    var deleteImageAction:() -> Void
    
    
    //MARK: - Body
    var body: some View {
        // Bottom toolBar
        VStack {
            
            if showImageBox {
                
                VStack(alignment: .leading) {
                    
                    HStack {
                        inputImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80, alignment: .center)
                            .overlay(
                            
                                Button(action: {
                                    
                                    deleteImageAction()
                                    
                                }, label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20, alignment: .center)
                                        .foregroundColor(Color("menu"))
                                        .padding(.trailing, -10)
                                        .padding(.top, 5)
                                })
                            
                                ,alignment: .topTrailing
                            )
                        Spacer()
                    }
                    .padding(.all, 10)
                }

            }
            
            HStack {

                //MARK: - Image Field
                
                 Menu(content: {
                 
                 Button {
                 
                    cameraAction()
                 
                 } label: {
                 Label("Camera", systemImage: "camera.on.rectangle")
                 }
                 
                 Button {
                    
                    gallaryAction()

                 } label: {
                 Label("Gallary", systemImage: "photo.on.rectangle.angled")
                 }
                 
                 
                 
                 }) {
                 Image(systemName: "camera.fill")
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .foregroundColor(Color("menu"))
                 .frame(width: 30, height: 20, alignment: .center)
                    .padding([.leading], 10)
                    .padding(.trailing, 10)

                 
                 }

                ZStack(alignment: .topLeading) {
                    
                    if messageText.isEmpty {
                        Text("send message ...")
                            .foregroundColor(Color.gray)
                            .padding(10)
                    }
                    
                    
                    DynamicHeightTextField(text: $messageText)
                     
                    
                    
                }
                .border(Color("menu"), width: 2)
                .cornerRadius(3.0)
                .padding([.top,.bottom], 10)
                Spacer()
                Button(action: {
                    
                      shareButtonAction()
                       
                }, label: {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color("menu"))
                        .frame(width: 30, height: 20, alignment: .center)
                    
                })

                Spacer(minLength: 10)
            }

            .frame(width: ScreenSize.SCREEN_WIDTH, height: 70, alignment: .center)
        }
    }
}

//MARK: - PreView
struct ChatBottomMenu_Previews: PreviewProvider {
    static var previews: some View {
        ChatBottomMenu(inputImage: .constant(Image("ic_profile_placeholder")), showImageBox: .constant(true), messageText: .constant(""), shareButtonAction: {
            
        }, cameraAction: {
            
        }, gallaryAction: {
            
        }, deleteImageAction: {
            
        })
            .previewLayout(.sizeThatFits)
    }
}
