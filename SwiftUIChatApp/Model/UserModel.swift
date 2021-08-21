//
//  UserModel.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 09/07/21.
//

import Foundation
import SwiftUI


let kFirstName = "firstName"
let klastName = "lastName"
let kEmail = "email"
let kUID = "uid"
let kIsOnline = "isOnline"


class UserModel: NSObject, NSCoding  {
    
    var firstName:String
    var lastName:String
    var email:String
    var uID:String
    var lastMessage:MessageModel
    var isOnline:Bool
    var isSelected:Bool = false
    var lastMessageString:String = ""
    var dateString = ""
    var avtarColor = Color(red: .random(in: 0.3...0.7), green: .random(in: 0.2...0.7), blue: .random(in: 0.1...0.7))
    
    // MARK: - init
    init(dictionary: [String:Any]) {
        
        self.firstName = dictionary[kFirstName] as? String ?? ""
        self.lastName = dictionary[klastName] as? String ?? ""
        self.email = dictionary[kEmail] as? String ?? ""
        self.uID = dictionary[kUID] as? String ?? ""
        let dataDict = dictionary[kLastMessage] as? [String:Any] ?? [:]
        self.lastMessage = MessageModel(dict: dataDict)
        self.isOnline = dictionary[kIsOnline] as? Bool ?? false
        
        
    }
    
    init(_ firstNameString:String = "",_ lastNameString:String = "",_ emilString:String = "",_ uidString:String = "",_ lastMessage:MessageModel = MessageModel(),_ isOnlineValue:Bool = false) {
        self.firstName = firstNameString
        self.lastName = lastNameString
        self.email = emilString
        self.uID = uidString
        self.lastMessage = lastMessage
        self.isOnline = isOnlineValue
        
    }
    
    
    
    // MARK: - NSCoding
    required init(coder aDecoder: NSCoder) {
        firstName = aDecoder.decodeObject(forKey: kFirstName) as? String ?? ""
        lastName = aDecoder.decodeObject(forKey: klastName) as? String ?? ""
        email = aDecoder.decodeObject(forKey: kEmail) as? String ?? ""
        uID = aDecoder.decodeObject(forKey: kUID) as? String ?? ""
        lastMessage = aDecoder.decodeObject(forKey: kLastMessage) as? MessageModel ?? MessageModel()
        isOnline = aDecoder.decodeObject(forKey: kIsOnline) as? Bool ?? false
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(firstName, forKey: kFirstName)
        aCoder.encode(lastName, forKey: klastName)
        aCoder.encode(email, forKey: kEmail)
        aCoder.encode(uID, forKey: kUID)
        aCoder.encode(lastName,forKey: kLastMessage)
        aCoder.encode(isOnline, forKey: kIsOnline)
        
    }
    
    ///Save user object in UserDefault
    func saveCurrentUserInDefault() {
        do {
            let endcodeData = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            UserDefaults.standard.set(endcodeData, forKey: UserDefaultsKey.kLoginUser)
        } catch {
            print(error)
        }
    }
    
    ///Get user object from UserDefault
    class func getCurrentUserFromDefault() -> UserModel? {
        do {
            if let decoded  = UserDefaults.standard.data(forKey: UserDefaultsKey.kLoginUser), let user = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as? UserModel {
                
                return user
            } else {
                print("Fail to Get the User model data.")
                return nil
            }
        } catch {
            print(error)
            return nil
        }
    }
    
    /// Get current user's user ID
    class func getCurrentUserID() -> String {
        var ID = String()
        guard let user = UserModel.getCurrentUserFromDefault() else {
            return "SDF"
        }
        ID = user.uID
        return ID
    }
    
    
    ///Remove user object from UserDefault
    class func removeUserFromDefault() {
        UserDefaults.standard.set(nil, forKey: UserDefaultsKey.kLoginUser)
    }
    
    
}
