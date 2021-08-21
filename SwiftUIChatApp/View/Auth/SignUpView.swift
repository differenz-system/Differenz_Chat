//
//  SignUpView.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 08/07/21.
//

import SwiftUI

struct SignUpView: View {
    
    //MARK: - Properties
    @StateObject var signupVM = SignupViewModel()
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    //MARK: - body
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    
                    
                    NavigationLink("", destination: HomeView(), tag: IdentifiableKeys.NavigationTags.knavToHome, selection: $signupVM.navigation)
                    
                    
                    ScrollView(.vertical, showsIndicators: false, content: {
                        
                        VStack(spacing: 20) {
                            
                            Spacer()
                            Text("FireBase Signup")
                                .fontWeight(.bold)
                                .font(.title)
                                .padding()
                            
                            TextField("FirstName", text: $signupVM.FirstNameTextField)
                                .keyboardType(.alphabet)
                                .font(.system(size: 16))
                                .frame(width: UIScreen.main.bounds.width*0.85, height: UIScreen.main.bounds.height*0.06, alignment: .center)
                                .padding(.leading)
                                .border(Color("menu"), width: 1)
                            
                            TextField("LastName", text: $signupVM.LastNameTextField)
                                .keyboardType(.alphabet)
                                .font(.system(size: 16))
//                                .foregroundColor(.black)
                                .frame(width: UIScreen.main.bounds.width*0.85, height: UIScreen.main.bounds.height*0.06, alignment: .center)
                                .padding(.leading)
                                .border(Color("menu"), width: 1)
                            
                            TextField("Email", text: $signupVM.emailTextField)
                                .keyboardType(.emailAddress)
                                .font(.system(size: 16))
//                                .foregroundColor(.black)
                                .frame(width: UIScreen.main.bounds.width*0.85, height: UIScreen.main.bounds.height*0.06, alignment: .center)
                                .padding(.leading)
                                .border(Color("menu"), width: 1)
                            
                            SecureField("Password", text: $signupVM.passwordTextField)
                                .keyboardType(.asciiCapable)
                                
                                .font(.system(size: 16))
//                                .foregroundColor(.black)
                                .frame(width: UIScreen.main.bounds.width*0.85, height: UIScreen.main.bounds.height*0.06, alignment: .center)
                                .padding(.leading)
                                .border(Color("menu"), width: 1)
                            
                            Button(action: {
                                signupVM.moveToHomeScreen()
                                
                            }, label: {
                                Text("Signup")
                                    .bold()
                                    .font(.system(size: 16))
                                    .foregroundColor(Color("menu"))
                                    .frame(width: UIScreen.main.bounds.width*0.89, height: UIScreen.main.bounds.height*0.06, alignment: .center)
                            })
                            .border(Color("menu"), width: 1)
                            
                            Button(action: {
                                mode.wrappedValue.dismiss()
                                
                            }, label: {
                                Text("Back To Login")
                                    .bold()
                                    .font(.system(size: 16))
                                    .foregroundColor(Color("menu"))
                                    .frame(width: UIScreen.main.bounds.width*0.89, height: UIScreen.main.bounds.height*0.06, alignment: .center)
                            })
                            .border(Color("menu"), width: 1)
                            .padding(.bottom, 50)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: geo.size.height, alignment: .center)
                        
                    })
                
                   
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                .progressHUD(isShowing: $signupVM.showLoadingIndicator)
                .alert(isPresented: $signupVM.showingError) {
                    Alert(title: Text(""), message: Text(signupVM.errorMessage), dismissButton: .default(Text(IdentifiableKeys.Buttons.kOK)) {
                    })
                }
            }
            .hideNavigationBar()
            
        }
        .hideNavigationBar()
    }
}


//MARK: - Preview
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .previewDevice("iPhone 11")
    }
}
