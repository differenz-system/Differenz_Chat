//
//  TableCell.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 09/07/21.
//

import SwiftUI

struct TableCell: View {
    
    //MARK: - Properties
    var initTitle:String
    var fullName:String
    var lastMessage:String
    var dateString:String
    var colorOFCircle:Color
    var activeStatusValue: activeStatus
    var buttonClick: () -> Void
    
    
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
                    .overlay(
                        
                        Circle()
                            .foregroundColor(self.activeStatusValue == activeStatus.hide ? .clear : self.activeStatusValue == activeStatus.active ? .green : .red)
                            .frame(width: 10, height: 10, alignment: .center)
                            .padding(.trailing, 3)
                        ,alignment: .bottomTrailing
                        
                    )
                
                VStack{
                    HStack{
                        Text(fullName)
                            .font(.title3)
                            .multilineTextAlignment(.leading)
                            .padding(.trailing, 10)
                        Spacer()
                        Text(dateString)
                            .font(.subheadline)
                    }
                    
                    
                    if lastMessage != "" {
                        HStack {
                            Text(lastMessage)
                                .font(.system(size: 14))
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                    
                    
                }
                .padding([.leading,.trailing], 3)
                
                Spacer()
                
            }
            .padding()
        }
    }
}

//MARK: - Preview
struct TableCell_Previews: PreviewProvider {
    
    static var previews: some View {
        TableCell(initTitle: "JR", fullName: "jeet rajput", lastMessage: "fndvjsnjkbdfsvjkbjkvbjkbvjkbjkvbj", dateString: "12/07/21", colorOFCircle: Color.blue, activeStatusValue: .active, buttonClick: {
            print("button click")
        })
        .previewLayout(.sizeThatFits)
        
    }
}
