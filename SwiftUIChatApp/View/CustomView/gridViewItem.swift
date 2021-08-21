//
//  gridViewItem.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 30/07/21.
//

import SwiftUI

struct gridViewItem: View {
    
    //MARK: - Properties
    var useName:String
    var initalizeName:String
    var activeStatusValue: activeStatus
    
    //MARK: - Body
    var body: some View {
        ZStack {
            
            GeometryReader(content: { geometry in
                VStack {
                    Text(initalizeName)
                        .font(.system(size: 30))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(self.activeStatusValue == activeStatus.hide ? Color("menu") : self.activeStatusValue == activeStatus.active ? .green : .red, lineWidth: 10)
                        )
                       
                }
                .background(Color.randomDark)
                .cornerRadius(20)
                .overlay(
                    
                    VStack {
                        
                        Text(useName)
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                            .lineLimit(1)
                            .frame(width: geometry.size.width, height: geometry.size.height/2, alignment: .center)
                            .background(Color.white.opacity(0.3))
                            .clipShape(CustomShape())
                            
                        
                    }
                    ,alignment: .bottom
                )
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            })
            
        }
        .frame(minWidth: 40, idealWidth: UIScreen.main.bounds.width*0.43 - 30, maxWidth: UIScreen.main.bounds.width*0.9, minHeight: 40, idealHeight: UIScreen.main.bounds.height*0.18, maxHeight: UIScreen.main.bounds.height*0.23, alignment: .center)
        
    }
}

//MARK: - Preview
struct gridViewItem_Previews: PreviewProvider {
    static var previews: some View {
        gridViewItem(useName: "Harris Roess", initalizeName: "HR", activeStatusValue: .hide)
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)
            .padding()
          
            
    }
}
