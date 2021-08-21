//
//  Extensions.swift
//  tec
//
//  Created by differenz147 on 22/06/21.
//

import Foundation
import SwiftUI


// MARK: - UserDefaults
extension UserDefaults {
    ///Bool : Is Registered User login or Not.
    class var isRegisteredUserLogin: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.kIsRegisteredUserLoggedIn)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.kIsRegisteredUserLoggedIn)
        }
    }

    
}


extension View {
    /// hide view
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
      switch shouldHide {
        case true: self.hidden()
        case false: self
      }
    }
    
    
    /**
     This method is used to hide navigation bar.
     */
    func hideNavigationBar() -> some View {
        self
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarBackButtonHidden(true)
            
    }
    
    
}

//MARK: - UIView  extension

extension UIView {
    
    /// round corners
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}


//MARK: - uiImage
extension UIImage {
    
    /// resize image
    func ResizeImageOriginalSize(targetSize: CGSize) -> UIImage? {
        
        var actualHeight: Float = Float(self.size.height)
        var actualWidth: Float = Float(self.size.width)
        let maxHeight: Float = Float(targetSize.height)
        let maxWidth: Float = Float(targetSize.width)
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight

        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, CGFloat(0))
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
}


//MARK: - String
extension String {
    
    /**
     This method is used to validate email field.
     - Returns: Return boolen value to indicate email is valid or not
     */
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9-]+\\.[A-Za-z]{1,}(\\.[A-Za-z]{1,}){0,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    /**
     This method is used to validate UserName field.
     - Returns: Return boolen value to indicate UserName is valid or not
     */
    func isValidUsername() -> Bool {
        // Length be 14 characters max and 3 characters minimum.
        let RegEx = "\\A\\w{3,12}\\z"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: self)
    }
    
    /**
     This method is used to validate password field.
     - Returns: Return boolen value to indicate password is valid or not
     */
    func isValidPassword() -> Bool {
        // Length be 6 characters minimum.
        guard self.count >= 6 else {
            return false
        }
        return true
    }
    
    
    /**
     This method is used to load image from URL.
     */
    func loadImage(placeholder: UIImage = UIImage(named: IdentifiableKeys.ImageName.kic_profile_placeholder) ?? UIImage()) -> UIImage{
        do{
            ///convert string to URl
            guard let url = URL(string: self)
            else{
                ///return empty image if the url is invalid
                return placeholder
            }
            
            ///convert the url to the data
            let data: Data  = try Data(contentsOf: url)
            return UIImage(data: data) ?? placeholder
            
        }
        catch{
            print("Not able to load image")
         }
         return placeholder
    }
    
    
    /**
     This method is used to white space from String.
     */
    public var trimWhiteSpace: String {
        get {
            return self.trimmingCharacters(in: .whitespaces)
        }
    }

    
}


//MARK: - Date
extension Date {
    
    /// convert int to date
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
   
    /// to generate timestamp
    var timeStamp:Double {
        return Double((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    var UTCTimeStamp : Double {
        let df = DateFormatter()
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = df.string(from: self)
        let utcDate = df.date(from: dateString) ?? Date()
        return utcDate.timeStamp
    }
    
    /// get date form UTC TimeStamp
    func getDateStringFromUTC(timeStamp: Int64) -> String {
        let date = Date(milliseconds: timeStamp)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MM/d/yy, hh:mm a"

        return dateFormatter.string(from: date)
    }
    
    /// get date form UTC TimeStamp with other date format
    func getDateStringFromUTC2(timeStamp: Int64) -> String {
        let date = Date(milliseconds: timeStamp)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMM d, yyyy"

        return dateFormatter.string(from: date)
    }
    
}


/// MARK: - Color Extension
extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0.1...0.9),
            green: .random(in: 0...1),
            blue: .random(in: 0.3...0.8)
        )
    }
    
    static var randomDark: Color {
        
        return Color(red: .random(in: 0.1...0.5), green: .random(in: 0.1...0.3), blue: .random(in: 0.1...0.6))
        
    }
    
}

//MARK: - Dismiss keyboard
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
