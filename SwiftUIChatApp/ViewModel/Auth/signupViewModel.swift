//
//  signupViewModel.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 09/07/21.
//

import Foundation

//Error enum
enum ErrorType: String {
    case server = "Error"
    case connection = "No connection"
    case response = ""
}

class SignupViewModel: ObservableObject {
    
    @Published var FirstNameTextField:String = ""
    @Published var LastNameTextField = ""
    @Published var emailTextField:String = ""
    @Published var passwordTextField = ""
    @Published var navigation:String? = nil
    @Published var showingError = false
    @Published var errorMessage : String = ""
    
    @Published var showLoadingIndicator = false
    
    private var db = Firestore.firestore()
    
    private var keyChainRef = KeychainSwift(keyPrefix: keyChainConstant.keyChainIdenitifier)
    
}

//MARK: - Helper method
extension SignupViewModel {
    
    
    
    /// signup in application and move to home screen
    func moveToHomeScreen() {
        guard self.checkValidatation() else { return }
        
        showLoadingIndicator = true
        createUser(email: emailTextField, password: passwordTextField) { (success, data)  in
            print(success)
            self.showLoadingIndicator = false
            guard let email = data?.user.email else {
                self.errorMessage = "unable to get data form server \n please try again later"
                self.showingError = true
                return
            }
            
            guard let uID = data?.user.uid else {
                self.errorMessage = "unable to get data form server \n please try again later"
                self.showingError = true
                return
            }
            
            let modelDict = [kFirstName: self.FirstNameTextField,klastName: self.LastNameTextField,kEmail: email,kUID: uID,kIsOnline: true] as [String : Any]
            self.db.collection(Constant.FireBase.userCollection).document(uID).setData(modelDict,merge: true)
            let userModelObj = UserModel(dictionary: modelDict)
            userModelObj.saveCurrentUserInDefault()
            UserDefaults.isRegisteredUserLogin = true
            self.navigation = IdentifiableKeys.NavigationTags.knavToHome
        } failure: { (fail) in
            self.showLoadingIndicator = false
            self.errorMessage = fail
            self.showingError = true
            print(fail)
        }
        
        
        
        
    }
    
    /// validate textfield
    /// - Returns: return true or false
    func checkValidatation() -> Bool {
        if self.FirstNameTextField.trimWhiteSpace.isEmpty {
            errorMessage = IdentifiableKeys.ValidationMessages.kEmptyFirstName
            showingError = true
            return false
        }else if !self.FirstNameTextField.trimWhiteSpace.isValidUsername() {
            errorMessage = IdentifiableKeys.ValidationMessages.kInValidFirstName
            showingError = true
            return false
        }else if self.LastNameTextField.trimWhiteSpace.isEmpty {
            errorMessage = IdentifiableKeys.ValidationMessages.kEmptyLastName
            showingError = true
            return false
        }else if !self.LastNameTextField.trimWhiteSpace.isValidUsername() {
            errorMessage = IdentifiableKeys.ValidationMessages.kInValidLastName
            showingError = true
            return false
        }else if self.emailTextField.trimWhiteSpace.isEmpty {
            errorMessage = IdentifiableKeys.ValidationMessages.kEmptyEmail
            showingError = true
            return false
        }else if !self.emailTextField.trimWhiteSpace.isValidEmail() {
            errorMessage = IdentifiableKeys.ValidationMessages.kInValidEmail
            showingError = true
            return false
        }
        else if self.passwordTextField.trimWhiteSpace.isEmpty {
            errorMessage = IdentifiableKeys.ValidationMessages.kEmptyPassword
            showingError = true
            return false
            
        }
        else if !self.passwordTextField.trimWhiteSpace.isValidPassword() {
            errorMessage = IdentifiableKeys.ValidationMessages.kInvalidPassword
            showingError = true
            return false
        }
        return true
    }
}

//MARK: - firebase auth

extension SignupViewModel {
    
    /// add email and password in keychain
    /// - Parameters:
    ///   - email: email string
    ///   - password: password string
    ///   - completion: escaping nil
    func addCredentialInKeyChain(email:String, password:String,completion: @escaping () -> Void) {
        
        if keyChainRef.set(email, forKey: keyChainConstant.emailString, withAccess: .accessibleWhenUnlocked) {
            
            print("email added in keychain successfully")
            
            
        }
        if keyChainRef.set(password, forKey: keyChainConstant.passwordString, withAccess: .accessibleWhenUnlocked) {
            
            print("password added in keychain successfully")
            
        }
        completion()
        
    }
    
    
    /// get email and password form keychain
    /// - Parameter completion: escaping with email and password string
    func getCredentialFormKeyChain(completion: @escaping (_ email:String,_ password:String) -> Void) {
        
        guard let email = keyChainRef.get(keyChainConstant.emailString) else {
            return
        }
        
        guard let password = keyChainRef.get(keyChainConstant.passwordString) else {
            return
        }
        
        completion(email,password)
        
    }
    
    
    /// create new user
    /// - Parameters:
    ///   - email: email text
    ///   - password: passord text
    ///   - success: escaping with firebase suth data
    ///   - failure: escaping with failure error
    func createUser(email: String, password: String, success: @escaping ( _ message: String, _ authdata: AuthDataResult?) -> (), failure: @escaping (_ error: String) -> Void){
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                
                
                failure(error?.localizedDescription ?? "error occur")
                
                
            } else {
                self.addCredentialInKeyChain(email: email, password: password) {
                    
                    self.getCredentialFormKeyChain { (email, password) in
                        
                        print(email)
                        print(password)
                        
                    }
                    
                    success(user.debugDescription, user)
                }
                
            }
            
        }
    }
    
    
}
