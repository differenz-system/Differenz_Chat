//
//  Constant.swift
//  DifferenzSystem
//
//  Created by differenz83 on 18/03/21.
//

import Foundation
import SwiftUI

// MARK: - Constant
class Constant {

    //MARK: - FireBase Collection Name
    struct FireBase {
        static let userCollection = "Users"
        static let ChatCollection = "Chat"
        static let messagesCollection = "messages"
        static let conversationCollection = "conversations"
        static let groupCollection = "group"
    }

}

//MARK: - iPhone Screensize
struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

//iPhone devicetype
struct DeviceType {
    static let IS_IPHONE_4_OR_LESS  = ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_X          = ScreenSize.SCREEN_HEIGHT == 812.0
    
    static let IS_IPHONE_XMAX          = ScreenSize.SCREEN_HEIGHT == 896.0
    static let IS_PAD               = UIDevice.current.userInterfaceIdiom == .pad
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
    //IPAD Device Constants
    static let IsDeviceIPad = IS_PAD || IS_IPAD || IS_IPAD_PRO ? true : false
}

//MARK: - ScreenControlsMultipliers
struct ScreenControlsMultipliers {
    static let kHeightOfNavigationbar: CGFloat  = 40
    static let kHeaderImageWidth: CGFloat       = ScreenSize.SCREEN_WIDTH - (DeviceType.IsDeviceIPad ? 160 : 120)
    static let kHeightOfTextField               = ScreenSize.SCREEN_HEIGHT * 0.065
    static let kHeightOfAppButton               = ScreenSize.SCREEN_HEIGHT * 0.065
    static let kHeightOfMaleFemaleSelection     = ScreenSize.SCREEN_HEIGHT * 0.05
    static let kHeightOfAchivement              = ScreenSize.SCREEN_HEIGHT * 0.06
    static let kHeightOfSearchBar: CGFloat      = DeviceType.IsDeviceIPad ? 55 : 45/*ScreenSize.SCREEN_HEIGHT * 0.055*/
    static let kHeightOfImage : CGFloat         = ScreenSize.SCREEN_WIDTH * 0.5
}

// MARK: - User Defaults Key Constant
struct UserDefaultsKey {
    static let kIsRegisteredUserLoggedIn                = "isRegisteredUserLoggedIn"
    static let kLoginUser                               = "loginUser"
    static let kWidgetData                              = "widgetData"
}



