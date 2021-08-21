//
//  ShowImageView.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 27/07/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct ShowImageView: View {
    
    //MARK: - Variable
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var imageURL:String
    @Binding var showImage:Bool
    
    //MARK: - Body
    var body: some View {
        ZStack {
            
            Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
            
            if showImage {
                
                ZStack {
                    
                    VStack {
                        
                        AnimatedImage(url: URL(string: imageURL))
                            .resizable()
                            .indicator(.activity)
                            .aspectRatio(contentMode: .fit)
                            .frame(minWidth: 0, idealWidth: 240, maxWidth: UIScreen.main.bounds.width*0.90, minHeight: 0, idealHeight: 240, maxHeight: UIScreen.main.bounds.height*0.7, alignment: .center)
                        
                        
                    }
                    
                    
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.9, alignment: .center)
                .overlay(
                    
                    Button(action: {
                        
                        showImage.toggle()
                        
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50, alignment: .center)
                    })
                    .padding(.trailing, 20)
                    ,alignment: .topTrailing
                
                )
                
            }
            
        }
    }
}

//MARK: - Preview
struct ShowImageView_Previews: PreviewProvider {
    static var previews: some View {
        ShowImageView(imageURL: "", showImage: .constant(true))
            .previewDevice("iPhone 11")
    }
}
