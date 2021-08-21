//
//  LogInView.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 08/07/21.
//

import SwiftUI



struct keyChainConstant {
    
    static let keyChainIdenitifier = "swiftChatApp_"
    static let passwordString = "passwordString"
    static let emailString = "emailString"
    
}


struct LogInView: View {
    
    //MARK: - Properties
    @StateObject var loginVM = LoginViewModel()
    
    //MARK: - Body
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    
                    NavigationLink("", destination: SignUpView(), tag: IdentifiableKeys.NavigationTags.knavToSignup, selection: $loginVM.navigation)
                    NavigationLink("", destination: HomeView(), tag: IdentifiableKeys.NavigationTags.knavToHome, selection: $loginVM.navigation)
                    
                   
                    ScrollView(.vertical, showsIndicators: false, content: {
                        VStack(spacing: 20) {
                            Spacer()
                            Text("FireBase Login")
                                .fontWeight(.bold)
                                .font(.title)
                                .padding()

                            TextField("Email", text: $loginVM.emailTextField)
                                .keyboardType(.emailAddress)
                                .font(.system(size: 16))
                                .frame(width: UIScreen.main.bounds.width*0.85, height: UIScreen.main.bounds.height*0.06, alignment: .center)
                                .padding(.leading)
                                .border(Color("menu"), width: 1)
                            
                            
                            SecureField("Password", text: $loginVM.passwordTextField)
                                .keyboardType(.asciiCapable)
                                .font(.system(size: 16))
                                .frame(width: UIScreen.main.bounds.width*0.85, height: UIScreen.main.bounds.height*0.06, alignment: .center)
                                .padding(.leading)
                                .border(Color("menu"), width: 1)
                            
                            HStack(alignment: .center, spacing: 15, content: {
                                Button(action: {
                                    
                                    loginVM.moveToHomeScreen()
                                    
                                }, label: {
                                    Text("Signin")
                                        .bold()
                                        .font(.system(size: 16))
                                        .foregroundColor(Color("menu"))
//                                        .foregroundColor(.black)
                                        .frame(width: UIScreen.main.bounds.width*0.425, height: UIScreen.main.bounds.height*0.06, alignment: .center)
                                })
                                .border(Color("menu"), width: 1)
                                
                                Button(action: {
                                    
                                    loginVM.moveToSignUp()
                                   
                                    
                                }, label: {
                                    Text("Signup")
                                        .bold()
                                        .font(.system(size: 16))
                                        .foregroundColor(Color("menu"))
//                                        .foregroundColor(.black)
                                        .frame(width: UIScreen.main.bounds.width*0.425, height: UIScreen.main.bounds.height*0.06, alignment: .center)
                                })
                                .border(Color("menu"), width: 1)
                            })
                            .frame(width: UIScreen.main.bounds.width*0.85, height: UIScreen.main.bounds.height*0.06, alignment: .center)
                        
                            Text("OR")
                                .bold()
                                .font(.system(size: 16))
                                .foregroundColor(Color("menu"))
                                .padding(.top, 20)
                            
                            Button(action: {
                                
                                // biometric auth
                                loginVM.bioMetricLoginAction()
                                
                                
                            }, label: {
                                HStack {
                                    
                                    Image(systemName: "faceid")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(Color("menu"))
                                        .frame(width: 40, height: 40, alignment: .center)
                                        .padding(.trailing, 20)
                                    Text(loginVM.authButtonText)
                                        .bold()
                                        .font(.system(size: 16))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Color("menu"))
                                    
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding()
                                .border(Color("menu"), width: 1)
                                .padding(.bottom, 30)
                                .frame(width: UIScreen.main.bounds.width*0.85)
                                
                                    
                            })
                            
                            
                            
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: geo.size.height, alignment: .center)
                    })
                    .onAppear(perform: {
                        
                        loginVM.loadEmailPassword()
                        
                        
                    })
                    
                   
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                .progressHUD(isShowing: $loginVM.showLoadingIndicator)
                .alert(isPresented: $loginVM.showingError) {
                    Alert(title: Text(""), message: Text(loginVM.errorMessage), dismissButton: .default(Text(IdentifiableKeys.Buttons.kOK)) {
                    })
                }
            }
            .hideNavigationBar()
            
        }
        .hideNavigationBar()
    }
}

//MARK: - Preview
struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
            .previewDevice("iPhone 11")
            
    }
}
