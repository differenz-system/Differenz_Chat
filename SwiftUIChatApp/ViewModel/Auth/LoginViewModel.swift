//
//  LoginViewModel.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 08/07/21.
//

import Foundation
import LocalAuthentication

//MARK:- For select type of your biometric
enum BiometricType{
    case touchID
    case faceID
    case none
}

//MARK: - LoginViewModel
class LoginViewModel: ObservableObject {
    
    @Published var emailTextField:String = ""
    @Published var passwordTextField = ""
    @Published var navigation:String? = nil
    @Published var signUpButton = false
    ///validation
    @Published var showingError = false
    @Published var errorMessage : String = ""
    @Published var showLoadingIndicator = false
    @Published var authEmail = ""
    @Published var authPassword = ""
    @Published var authButtonText = "Login with Face ID"
    
    private var db = Firestore.firestore()
    
    private var keyChainRef = KeychainSwift(keyPrefix: keyChainConstant.keyChainIdenitifier)
    
}


//MARK: - Helper method
extension LoginViewModel {
    
    /// got o signup screen
    func moveToSignUp() {
        
        self.navigation = IdentifiableKeys.NavigationTags.knavToSignup
    }
    
    
    /// check validation
    /// - Returns: return true or false
    func checkValidatation() -> Bool {
        if self.emailTextField.trimWhiteSpace.isEmpty {
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

//MARK: - bioMetric login
extension LoginViewModel {
    
    /// bio metric login
    func bioMetricLoginAction() {
        
        if  self.authEmail == "" || self.authPassword == "" {
            self.showingError = true
            self.errorMessage = "To Use Face ID for login you need to login first"
            return
        }
        
        let context = LAContext()
        let reason = "use face id for Local Authentication"
        var authError: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
                if success {
                    DispatchQueue.main.async {
                        
                        self.emailTextField = self.authEmail
                        self.passwordTextField = self.authPassword
                        
                        self.moveToHomeScreen()
                        
                        
                    }
                    
                    
                }
                
            }
            
        } else {
            
            switch authError {
            case LAError.authenticationFailed?:
                self.showingError = true
                self.errorMessage = "There was a problem verifying your identity."
            case LAError.userCancel?:
                self.showingError = true
                self.errorMessage = "You pressed cancel."
            case LAError.userFallback?:
                self.showingError = true
                self.errorMessage = "You pressed password."
            case LAError.biometryNotAvailable?:
                self.showingError = true
                self.errorMessage = "Face ID/Touch ID is not available."
            case LAError.biometryNotEnrolled?:
                self.showingError = true
                self.errorMessage = "Face ID/Touch ID is not set up."
            case LAError.biometryLockout?:
                self.showingError = true
                self.errorMessage = "Face ID/Touch ID is locked."
            default:
                self.showingError = true
                self.errorMessage = "Face ID/Touch ID may not be configured"
            }
            
        }
        
        
        
    }
    
    
    /// get avaliable biometric sensor
    /// - Returns: return biometric type
    func getBiometricType() -> BiometricType {
        let authenticationContext = LAContext()
        authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch (authenticationContext.biometryType){
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        default:
            return .none
        }
    }
    
    
    /// set title to biometric auth button
    func loadEmailPassword() {
        
        getCredentialFormKeyChain { (email, password) in
            self.authEmail = email
            self.authPassword = password
        }
        
        if self.authEmail == "" || self.authPassword == "" {
            self.authButtonText = "To Use Face ID for login you need to login first"
        } else {
            
            if getBiometricType() == .faceID {
                
                self.authButtonText = "Login with Face ID"
                
            } else if getBiometricType() == .touchID {
                
                self.authButtonText = "Login with Touch ID"
                
            }
            
        }
        
        
        
    }
    
    
    /// add email and password in key chain
    /// - Parameters:
    ///   - email: email id
    ///   - password: password
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
    
    /// get email and password foem key chain
    /// - Parameter completion: escaping with email and password
    func getCredentialFormKeyChain(completion: @escaping (_ email:String,_ password:String) -> Void) {
        
        guard let email = keyChainRef.get(keyChainConstant.emailString) else {
            return
        }
        
        guard let password = keyChainRef.get(keyChainConstant.passwordString) else {
            return
        }
        
        completion(email,password)
        
    }
    
    
}

//MARK: - firebase auth
extension LoginViewModel {
    
    /// login
    /// - Parameters:
    ///   - email: email id
    ///   - password: password
    ///   - success: escaping with success message and auth data
    ///   - failure: escapping with failure error
    func logIn(email: String, password: String, success: @escaping ( _ message: String, _ authdata: AuthDataResult?) -> (), failure: @escaping (_ error: String) -> Void){
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                
                failure(error?.localizedDescription ?? "signIn Error")
                
            } else {
                
                self.addCredentialInKeyChain(email: email, password: password) {
                    
                    success(user.debugDescription, user)
                }
                
            }
            
        }
        
    }
    
    
    ///  firbase login and move to home screen
    func moveToHomeScreen() {
        guard self.checkValidatation() else { return }
        
        
        showLoadingIndicator = true
        
        logIn(email: emailTextField, password: passwordTextField) { (message, data) in
            
            guard let uID = data?.user.uid else {
                self.errorMessage = "unable to get data form server \n please try again later"
                self.showingError = true
                return
            }
            
            guard let email = data?.user.email else {
                self.errorMessage = "unable to get data form server \n please try again later"
                self.showingError = true
                return
            }
            
            self.db.collection(Constant.FireBase.userCollection).document(uID).getDocument { (document, error) in
                
                self.showLoadingIndicator = false
                
                if error != nil {
                    self.showLoadingIndicator = false
                    self.errorMessage = error?.localizedDescription ?? "unable to get data user data form server"
                    self.showingError = true
                    print(error?.localizedDescription as Any)
                    
                    
                } else {
                    if let document = document, document.exists {
                        self.showLoadingIndicator = false
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        print("Document data: \(dataDescription)")
                        guard let firstName = document.get(kFirstName) as? String else {
                            self.errorMessage = "unable to get data form server \n please try again later"
                            self.showingError = true
                            return
                        }
                        guard let lastName = document.get(klastName) as? String else {
                            self.errorMessage = "unable to get data form server \n please try again later"
                            self.showingError = true
                            return
                        }
                        
                        let modelDict:[String:Any] = [kFirstName: firstName, klastName: lastName, kEmail:email, kUID: uID,kIsOnline: true]
                        self.db.collection(Constant.FireBase.userCollection).document(uID).setData(modelDict,merge: true)
                        let userModelObj = UserModel(dictionary: modelDict)
                        userModelObj.saveCurrentUserInDefault()
                        UserDefaults.isRegisteredUserLogin = true
                        
                        self.navigation = IdentifiableKeys.NavigationTags.knavToHome
                        
                    } else {
                        self.showLoadingIndicator = false
                        self.errorMessage = "data don't exist \n try again later or create new account"
                        self.showingError = true
                        print("Document does not exist")
                    }
                }
                
            }
            
            
            
        } failure: { (fail) in
            self.showLoadingIndicator = false
            self.errorMessage = fail
            self.showingError = true
            print(fail)
        }
        
        
        
    }
    
}
