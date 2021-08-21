//
//  ProgressHUD.swift
//  DifferenzSystem
//
//  Created by differenz83 on 18/03/21.
//

import Foundation
import SwiftUI

extension View {
    public func progressHUD(
        isShowing: Binding<Bool>,
        type: ProgressHUDType = .default,
        blurBackground: Bool = true) -> some View {
        ProgressHUD(isShowing: isShowing,
                    type: type,
                    blurBackground: blurBackground,
                    presenting: { self })
    }
}

public enum ProgressHUDType {
    case `default`
    case success
    case error
    case info
}

struct ProgressHUD<Presenting>: View where Presenting: View {
    /// Show Progress HUD
    @Binding var isShowing: Bool
    
    /// Progress HUD Type
    let type: ProgressHUDType
    
    /// Blur the background behind the ProgressHUD
    let blurBackground: Bool
    
    /// The view that will be behind the ProgressHUD
    let presenting: () -> Presenting
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack(alignment: .center) {
                
                self.presenting()
                    .blur(radius: (self.isShowing && self.blurBackground) ? 1 : 0)
                    .disabled(self.isShowing ? true : false)
                
                VStack {
                    
                    if self.type == .error {
                        Image(systemName: "xmark").resizable().frame(width: 30, height: 30).padding(.leading, 16).padding(.trailing, 16)
                    } else if self.type == .success {
                        Image(systemName: "checkmark").resizable().frame(width: 30, height: 30)
                    } else if self.type == .info {
                        Image(systemName: "info.circle").resizable().frame(width: 30, height: 30)
                    } else {
                        if #available(iOS 14.0, *) {
                            ProgressView()
                        }
                    }
                }.padding(20)
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
                    .opacity(self.isShowing ? 1 : 0)
                
            }
        }
    }
}

