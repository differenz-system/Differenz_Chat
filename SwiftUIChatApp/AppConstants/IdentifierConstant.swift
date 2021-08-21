//
//  IdentifierConstant.swift
//  DifferenzSystem
//
//  Created by differenz83 on 20/03/21.
//

import Foundation


//MARK: - Localization Keys
struct IdentifiableKeys {
    
    //MARK: Navigation Tags in App
    struct NavigationTags {
        static let knavToHome                   = "navToHome"
        static let knavToChatUser               = "navToChatUser"
        static let knavToChat                   = "navToChat"
        static let kNavToLogin                  = "NavToLogin"
        static let knavToSignup                 = "navToSignup"
        static let knavToGroupChat              = "navToGroupChat"
        static let knavToGroupList              = "navToGroupList"

    }
    
    //MARK: - Button
    struct Buttons {
        
        //Alert Buttons
        static let kOK                          = "OK"
        static let kOk                          = "Ok"
        static let kDONE                        = "DONE"
        static let kDone                        = "Done"
        static let kDelete                      = "Delete"
        static let kLogout                      = "Logout"
        static let kCancel                      = "Cancel"
    }
    
    //MARK: - Assets Image name
    struct ImageName {
    
        static let kic_profile_placeholder      = "ic_profile_placeholder"
        
    }
    
    //MARK: - Validation Messages Keys
    struct ValidationMessages {
        
        //Authentication
        static let kEmptyFirstName              = "Please enter first name."
        static let kEmptyLastName               = "Please enter last name."
        static let kEmptyUserName               = "Please enter username."
        static let kEmptyEmail                  = "Please enter email."
        static let kInValidEmail                = "Please enter valid email."
        static let kInValidFirstName            = "Please enter valid first name."
        static let kInValidLastName             = "Please enter valid last name."
        static let kInvalidUserName             = "Please enter valid username."
        static let kEmptyPassword               = "Please enter password."
        static let kInvalidPassword             = "Password should contain at least 6 characters."
        
        
        // error
        static let kerrorOccur                  = "error occur"
        static let kSourceNotAvaliable          = "Source not avaliable"
        static let kMaxUserLimitReached         = "Max User limit reached"
        static let kOnlyAdminCanAddUsers        = "only Admin can add users"
        static let kOnlyAdminCanDelete          = "only Admin can delete users form group"
        static let kPleaseTryAgainLater         = "Please try again later"
        static let kLeaveGroup                  = "Leave Group"
        static let kLeaveGorupWraning           = "after leaving this group you are unable to do conversation in this group"
        static let kOpenSetting                 = "Open Setting"
        static let kProvideAccessToTakePhoto    = "Provide access to take photo"

    }
    
    //MARK: - AlertTypes
    struct alertTypes {
      
        static let kShowUnableToAddUser          = "showUnableToAddUser"
        static let kShowUnableToDeleteUser       = "showUnableToDeleteUser"
        static let kShowLeaveGroupAlert          = "showLeaveGroupAlert"
        static let kShowDeleteGroup              = "showDeleteGroup"
        static let kShowLimitAlert               = "showLimitAlert"
        static let kSourceNotFound               = "sourceNotFound"
        static let kOtherError                   = "otherError"
    }
    
    //MARK: - SheetTypes
    struct sheetTypes {
        
        static let kOpenCamera              = "openCamera"
        static let kOpenGallary             = "openGallary"
        static let kOpenAddList             = "openAddList"
        static let kOpenDeleteList          = "openDeleteList"
        static let kOpenUsersList           = "openUsersList"
        static let kOpenForwardList         = "openForwardList"
        
    }
    
   
}
