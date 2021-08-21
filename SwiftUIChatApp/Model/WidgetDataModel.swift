//
//  WidgetDataModel.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 06/08/21.
//

import Foundation
import SwiftUI

let kArrOfUsers = "arrOfUsers"
let kArrOfGroups = "arrOfGroups"

class WidgetDataModel: NSObject, NSCoding {
   

    var arrOfUsers: [UserModel]
    var arrOfGroups: [GroupModel]
   
    init(dictionary: [String:Any]) {
        
        let arrOfUsersData = dictionary[kArrOfUsers] as? [[String:Any]] ?? []
        self.arrOfUsers = arrOfUsersData.compactMap(UserModel.init)
        let arrOfGroupData = dictionary[kArrOfGroups] as? [[String:Any]] ?? []
        self.arrOfGroups = arrOfGroupData.compactMap(GroupModel.init)
        
    }
    
    required init(coder aDecoder: NSCoder) {

        self.arrOfUsers = aDecoder.decodeObject(forKey: kArrOfUsers) as? [UserModel] ?? []
        self.arrOfGroups = aDecoder.decodeObject(forKey: kArrOfGroups) as? [GroupModel] ?? []
    }
    
    
    func encode(with coder: NSCoder) {
        coder.encode(arrOfUsers,forKey: kArrOfUsers)
        coder.encode(arrOfGroups,forKey: kArrOfGroups)
    }
    
    /// Save widget data in user
    func saveCurrentUserInDefault() {
        // kWidgetData
        do {
            let endcodeData = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            UserDefaults.standard.set(endcodeData, forKey: UserDefaultsKey.kWidgetData)
            
        } catch{
            print(error)
        }
    }
    
    /// get  widget data
    class func getWidgetData() -> WidgetDataModel? {
        
        do{
            
            if let decoded  = UserDefaults.standard.data(forKey: UserDefaultsKey.kWidgetData), let widget = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as? WidgetDataModel {
                
                return widget
            } else {
                print("Fail to Get the User model data.")
                return nil
            }
            
            
        } catch {
            print(error)
            return nil
        }
        
    }
    
}
