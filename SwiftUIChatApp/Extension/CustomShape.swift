//
//  CustomShape.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 31/07/21.
//

import SwiftUI

//MARK: - Shape
struct CustomShape: Shape {
   
    func path(in ract: CGRect) -> Path {
        
        let path = UIBezierPath(roundedRect: ract, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
        
        return Path(path.cgPath)
    }
    
}

struct CustomShape_Previews: PreviewProvider {
    static var previews: some View {
        CustomShape()
            .previewLayout(.fixed(width: 420, height: 120))
            .padding()
    }
}
