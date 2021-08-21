//
//  ChatView.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 12/07/21.
//

import SwiftUI
import IQKeyboardManagerSwift


var isONAPperCall = false




struct ChatView: View {

    //MARK: - Properties
    @StateObject var model = ChatViewModel()
    @StateObject var stroageVM = firebaseStorageViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var userObj:UserModel?
    @State var groupOBJ:GroupModel?
    @State var inputImage: UIImage?
    @State var imageOfBox = Image("ic_profile_placeholder")
    @State var showImageBox: Bool = false
    @State var imageStringWithToken:String = ""
    @State var imageURL:URL?
    @State var cellINdex = 1
    
    
    
    var isGroupChat:Bool
    
    
    
    //MARK: - Body
    var body: some View {
        
        
        Group {
            
            ZStack {
                
                
                
                
                // to solve navigation Back issue and onAPper Call Issue while app on background (14.5 / 14.6)
                NavigationLink(destination: EmptyView()) {
                    EmptyView()
                }
                
                VStack {
                    
                    // chat  custom navbar
                    ChatNavBar(circleText: isGroupChat ? "\(groupOBJ?.title.prefix(2).uppercased() ?? "TE")" : "\(userObj?.firstName.prefix(1).uppercased() ?? "F")\(userObj?.lastName.prefix(1).uppercased() ?? "L")", headlineText: isGroupChat ? "\(groupOBJ?.title ?? "Title")" : "\(userObj?.firstName ?? "firstName") \(userObj?.lastName ?? "lastName")", subHeadlineText: model.adminName, isFromGorupList: isGroupChat, isHideADDButton: (isGroupChat && (groupOBJ?.admin != UserModel.getCurrentUserID())), activeStatusValue: isGroupChat ? .hide : userObj?.isOnline ?? true ? .active : .inactive) {
                        
                        presentationMode.wrappedValue.dismiss()
                        
                        
                    } addButtonAction: {
                        
                        if !isGroupChat {
                            
                            model.openSheet = true
                            model.showSheetTypes = IdentifiableKeys.sheetTypes.kOpenAddList
                            
                        } else {
                            
                            guard let groupModel = groupOBJ else {
                                return
                            }
                            
                            if groupModel.admin == UserModel.getCurrentUserID() {
                                
                                if groupModel.userIds.count == 5 {
                                    model.showAlert = true
                                    model.showAlertTypes = IdentifiableKeys.alertTypes.kShowLimitAlert
                                } else {
                                    model.openSheet = true
                                    model.showSheetTypes = IdentifiableKeys.sheetTypes.kOpenAddList
                                }
                                
                                
                            } else {
                                
                                model.showAlert = true
                                model.showAlertTypes = IdentifiableKeys.alertTypes.kShowUnableToAddUser
                                
                            }
                            
                        }
                        
                    } deleteButtonAction: {
                        
                        guard let groupModel = groupOBJ else {
                            return
                        }
                        
                        if groupModel.admin == UserModel.getCurrentUserID() {
                            
                            model.openSheet = true
                            model.showSheetTypes = IdentifiableKeys.sheetTypes.kOpenDeleteList
                            
                        } else {
                            model.showAlert = true
                            model.showAlertTypes = IdentifiableKeys.alertTypes.kShowLeaveGroupAlert
                        }
                        
                    } showUserListAction: {
                        
                        model.openSheet = true
                        model.showSheetTypes = IdentifiableKeys.sheetTypes.kOpenUsersList
                        
                    }
                    
                    
                    
                    if model.arrMessageData.isEmpty {
                        
                        Spacer()
                        
                        Text("No message found")
                            .bold()
                            .font(.title)
                        
                        Spacer()
                        
                    } else {
                        
                        ScrollViewReader { scrollValue in
                            ChatScrollView(.vertical) {
                                LazyVStack {
                                    
                                    if isGroupChat {
                                        
                                        ForEach(0..<model.arrMessageData.count, id:\.self) { index in
                                            
                                            GroupChatCell(position: model.arrayOfPositions[index], color: model.arrayOfPositions[index] == BubblePosition.right ? .green : .blue, chatText: model.arrMessageData[index].body, userName: model.arrMessageData[index].userName, TimeStamp: "\(Date().getDateStringFromUTC(timeStamp: model.arrOfTimeStamp[index]))", messageType: model.arrMessageData[index].messageType, imageURL: model.arrMessageData[index].imageURL) {
                                                
                                                // copy text in keyBoard
                                                let pasteboard = UIPasteboard.general
                                                pasteboard.string = model.arrMessageData[index].body
                                                
                                            } openImage: {
                                                // open image
                                                model.openImage(imageUrl: model.arrMessageData[index].imageURL)
                                            } forwardMessage: {
                                                
                                                guard let groupModel = groupOBJ else {
                                                    return
                                                }
                                                
                                                model.chatUserID = groupModel.groupID
                                                model.selectedMessage = model.arrMessageData[index]
                                                model.openSheet = true
                                                model.isFromGroup = true
                                                model.showSheetTypes = IdentifiableKeys.sheetTypes.kOpenForwardList
                                                
                                            } deleteMessage: {
                                                guard let groupModel = groupOBJ else {
                                                    return
                                                }
                                                
                                                model.deleteMessageFromGroupCollcetion(groupID: groupModel.groupID, messageID: model.arrMessageData[index].documentId, messageType: model.arrMessageData[index].messageType, imageFileURL: model.arrMessageData[index].imageURL, groupModel: groupModel)
                                            }
                                            
                                            
                                            
                                        }
                                        
                                    } else {
                                        
                                        ForEach(0..<model.arrMessageData.count, id:\.self) { index in
                                            
                                            ChatCell(position: model.arrayOfPositions[index], color: model.arrayOfPositions[index] == BubblePosition.right ?.green : .blue, chatText: model.arrMessageData[index].body, TimeStamp: "\(Date().getDateStringFromUTC(timeStamp: model.arrOfTimeStamp[index]))", messageType: model.arrMessageData[index].messageType, imageURL: model.arrMessageData[index].imageURL) {
                                                
                                                // copy text in keyBoard
                                                let pasteboard = UIPasteboard.general
                                                pasteboard.string = model.arrMessageData[index].body
                                                
                                            } openImage: {
                                                
                                                // open image
                                                model.openImage(imageUrl: model.arrMessageData[index].imageURL)
                                                
                                            } forwardMessage: {
                                                
                                                guard let userModel = userObj else {
                                                    return
                                                }
                                                
                                                model.chatUserID = userModel.uID
                                                model.selectedMessage = model.arrMessageData[index]
                                                model.openSheet = true
                                                model.isFromGroup = false
                                                model.showSheetTypes = IdentifiableKeys.sheetTypes.kOpenForwardList
                                                
                                            } deleteMessage: {
                                                
                                                guard let userModel = userObj else {
                                                    return
                                                }
                                                
                                                model.deleteMessage(senderID: UserModel.getCurrentUserID(), receriverID: userModel.uID, messageID: model.arrMessageData[index].documentId, messageType: model.arrMessageData[index].messageType, imageFileURL: model.arrMessageData[index].imageURL, userModel: userModel)
                                                
                                                
                                            }
                                            
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    
                                }
                                .onChange(of: model.arrMessageData, perform: { value in
                                    scrollValue.scrollTo(model.arrMessageData.count - 1)
                                })
                                .onAppear(perform: {
                                    scrollValue.scrollTo(model.arrMessageData.count - 1)
                                })
                                
                            }.padding(.top)
                            
                            
                        }
                        
                    }
                    
                    
                    // Bottom toolBar
                    ChatBottomMenu(model: ChatViewModel(),inputImage: $imageOfBox, showImageBox: $showImageBox, messageText: $model.messageTextField, shareButtonAction: {
                        
                        if model.messageTextField != "" && self.inputImage != nil {
                            
                            if !isGroupChat {
                                
                                guard let userModel = userObj else {
                                    return
                                }
                                
                                guard let url = self.imageURL else {
                                    return
                                }
                                
                                guard let sendIMage = self.inputImage else {
                                    return
                                }
                                
                                stroageVM.uploadFile(image: sendIMage, fileURL: url) { (success, uploadedImageUrl) in
                                    
                                    if success {
                                        
                                        model.addMessageToCollection(senderID: UserModel.getCurrentUserID(), receriverID: userModel.uID, message: model.messageTextField, messageType: 3, imageurl: uploadedImageUrl, timeStamp: Date().UTCTimeStamp) { (messageData) in
                                            model.arrayOfPositions.append(BubblePosition.right)
                                            model.arrOfTimeStamp.append(Int64(Date().UTCTimeStamp))
                                            let messageDataModel = MessageModel(dict: messageData)
                                            
                                            model.arrMessageData.append(messageDataModel)
                                            self.showImageBox = false
                                            self.inputImage = nil
                                            model.messageTextField = ""
                                        }
                                        
                                        
                                    }
                                    
                                }
                                
                            } else {
                                
                                guard let groupModel = groupOBJ else {
                                    return
                                }
                                
                                guard let url = self.imageURL else {
                                    return
                                }
                                
                                guard let sendIMage = self.inputImage else {
                                    return
                                }
                                
                                stroageVM.uploadFile(image: sendIMage,fileURL: url) { (success, uploadedImageUrl) in
                                    
                                    if success {
                                        
                                        model.addMessageInGroupCollcetion(GroupID: groupModel.groupID, message: model.messageTextField, messageType: 3, imageurl: uploadedImageUrl, groupModel: groupModel) { (messageData) in
                                            
                                            
                                            model.arrayOfPositions.append(BubblePosition.right)
                                            
                                            model.arrOfTimeStamp.append(Int64(Date().UTCTimeStamp))
                                            
                                            let messageDataModel = MessageModel(dict: messageData)
                                            
                                            model.arrMessageData.append(messageDataModel)
                                            self.showImageBox = false
                                            self.inputImage = nil
                                            model.messageTextField = ""
                                        }
                                        
                                        
                                    }
                                    
                                }
                                
                                
                            }
                            
                            
                        } else if model.messageTextField != "" {
                            
                            
                            
                            if !isGroupChat {
                                
                                guard let userModel = userObj else {
                                    return
                                }
                                
                                model.addMessageToCollection(senderID: UserModel.getCurrentUserID(), receriverID: userModel.uID, message: model.messageTextField, messageType: 1, imageurl: "", timeStamp: Date().UTCTimeStamp) { (messageData) in
                                    model.arrayOfPositions.append(BubblePosition.right)
                                    model.arrOfTimeStamp.append(Int64(Date().UTCTimeStamp))
                                    let messageDataModel = MessageModel(dict: messageData)
                                    
                                    model.arrMessageData.append(messageDataModel)
                                    
                                    model.messageTextField = ""
                                }
                                
                            } else {
                                
                                guard let groupModel = groupOBJ else {
                                    return
                                }
                                
                                model.addMessageInGroupCollcetion(GroupID: groupModel.groupID, message: model.messageTextField, messageType: 1, imageurl: "", groupModel: groupModel) { (messageData) in
                                    
                                    
                                    model.arrayOfPositions.append(BubblePosition.right)
                                    
                                    model.arrOfTimeStamp.append(Int64(Date().UTCTimeStamp))
                                    
                                    let messageDataModel = MessageModel(dict: messageData)
                                    
                                    model.arrMessageData.append(messageDataModel)
                                    
                                    model.messageTextField = ""
                                }
                                
                            }
                            
                        } else if self.inputImage != nil {
                            
                            // share image
//                            guard let url = self.imageURL else {
//                                return
//                            }
                            guard let sendIMage = self.inputImage else {
                                return
                            }
                            
                            stroageVM.uploadFile(image: sendIMage,fileURL: self.imageURL) { (success, uploadedImageUrl) in
                                
                                if success {
                                    
                                    if !isGroupChat {
                                        
                                        guard let userModel = userObj else {
                                            return
                                        }
                                        
                                        model.addMessageToCollection(senderID: UserModel.getCurrentUserID(), receriverID: userModel.uID, message: model.messageTextField, messageType: 2, imageurl: uploadedImageUrl, timeStamp: Date().UTCTimeStamp) { (messageData) in
                                            model.arrayOfPositions.append(BubblePosition.right)
                                            model.arrOfTimeStamp.append(Int64(Date().UTCTimeStamp))
                                            let messageDataModel = MessageModel(dict: messageData)
                                            
                                            model.arrMessageData.append(messageDataModel)
                                            self.showImageBox = false
                                            self.inputImage = nil
                                        }
                                        
                                    } else {
                                        
                                        // group Chat
                                        guard let groupModel = groupOBJ else {
                                            return
                                        }
                                        
                                        model.addMessageInGroupCollcetion(GroupID: groupModel.groupID, message: model.messageTextField, messageType: 2, imageurl: uploadedImageUrl, groupModel: groupModel) { (messageData) in
                                            model.arrayOfPositions.append(BubblePosition.right)
                                            model.arrOfTimeStamp.append(Int64(Date().UTCTimeStamp))
                                            let messageDataModel = MessageModel(dict: messageData)
                                            
                                            model.arrMessageData.append(messageDataModel)
                                            self.showImageBox = false
                                            self.inputImage = nil
                                        }
                                        
                                        
                                    }
                                    
                                    
                                }
                                
                            }
                            
                        } else {
                            return
                        }
                        
                        
                    }, cameraAction: {
                        Utilities.checkCameraPermisson { (success) in
                            
                            if success {
                                
                                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                    
                                    DispatchQueue.main.async {
                                        model.openSheet = true
                                        model.showSheetTypes = IdentifiableKeys.sheetTypes.kOpenCamera
                                    }
                                    
                                } else {
                                    DispatchQueue.main.async {
                                        model.showAlert = true
                                        model.showAlertTypes = IdentifiableKeys.alertTypes.kSourceNotFound
                                    }
                                }
                                
                                
                                
                            } else {
                                DispatchQueue.main.async {
                                    model.showAlert = true
                                    model.showAlertTypes = ""
                                }
                            }
                            
                            
                        }
                    }, gallaryAction: {
                        Utilities.checkPhotoLibraryPermission { (success) in
                            
                            if success {
                                
                                DispatchQueue.main.async {
                                    model.openSheet = true
                                    model.showSheetTypes = IdentifiableKeys.sheetTypes.kOpenGallary
                                }
                                
                            } else {
                                DispatchQueue.main.async {
                                    model.showAlert = true
                                    model.showAlertTypes = ""
                                }
                            }
                            
                        }
                    }, deleteImageAction: {
                        
                        DispatchQueue.main.async {
                            self.showImageBox = false
                            self.inputImage = nil
                        }
                        
                    })
                    .onChange(of: inputImage, perform: { value in
                        
                        DispatchQueue.main.async {
                            if inputImage != nil {
                                self.showImageBox = true
                                let imageView = inputImage!.ResizeImageOriginalSize(targetSize: CGSize(width: 20, height: 20))
                                self.imageOfBox = Image(uiImage: imageView!)
                            }
                        }
                        
                        
                    })
                    
                    
                } // outer vStack
                .progressHUD(isShowing: $stroageVM.showLoader)
                if model.openImage {
                    
                    ShowImageView(imageURL: model.imageURL, showImage: $model.openImage)
                }
                
            } //: ZStack
            .alert(isPresented: $model.showAlert, content: { () -> Alert in
                
                var resultAlert = Alert(title: Text(IdentifiableKeys.ValidationMessages.kerrorOccur))
                
                switch model.showAlertTypes {
                case IdentifiableKeys.alertTypes.kSourceNotFound:
                    resultAlert = Alert(title: Text(IdentifiableKeys.ValidationMessages.kSourceNotAvaliable), dismissButton: Alert.Button.cancel(Text(IdentifiableKeys.Buttons.kOK)))
                case IdentifiableKeys.alertTypes.kShowLimitAlert:
                    resultAlert = Alert(title: Text(IdentifiableKeys.ValidationMessages.kMaxUserLimitReached), dismissButton: Alert.Button.cancel(Text(IdentifiableKeys.Buttons.kOK)))
                case IdentifiableKeys.alertTypes.kShowUnableToAddUser:
                    resultAlert = Alert(title: Text(IdentifiableKeys.ValidationMessages.kOnlyAdminCanAddUsers), dismissButton: Alert.Button.cancel(Text(IdentifiableKeys.Buttons.kOK)))
                case IdentifiableKeys.alertTypes.kShowUnableToDeleteUser:
                    resultAlert = Alert(title: Text(IdentifiableKeys.ValidationMessages.kOnlyAdminCanDelete), dismissButton: Alert.Button.cancel(Text(IdentifiableKeys.Buttons.kOK)))
                case IdentifiableKeys.alertTypes.kOtherError:
                    resultAlert = Alert(title: Text(IdentifiableKeys.ValidationMessages.kPleaseTryAgainLater), dismissButton: Alert.Button.cancel(Text(IdentifiableKeys.Buttons.kOK)))
                case IdentifiableKeys.alertTypes.kShowLeaveGroupAlert:
                    resultAlert = Alert(title: Text(IdentifiableKeys.ValidationMessages.kLeaveGroup), message: Text(IdentifiableKeys.ValidationMessages.kLeaveGorupWraning), primaryButton: Alert.Button.cancel(), secondaryButton: Alert.Button.destructive(Text(IdentifiableKeys.Buttons.kOK), action: {
                        
                        guard let groupModel = groupOBJ else {
                            return
                        }
                        
                        model.leaveGroup(groupID: groupModel.groupID) { (success) in
                            
                            if success {
                                
                                self.presentationMode.wrappedValue.dismiss()
                                
                            } else {
                                model.showAlert = true
                                model.showAlertTypes = IdentifiableKeys.alertTypes.kOtherError
                            }
                            
                        }
                        
                        
                    }))
                default:
                    resultAlert =  Alert(title: Text(IdentifiableKeys.ValidationMessages.kOpenSetting), message: Text(IdentifiableKeys.ValidationMessages.kProvideAccessToTakePhoto), primaryButton: Alert.Button.cancel(Text(IdentifiableKeys.Buttons.kCancel)), secondaryButton: Alert.Button.default(Text(IdentifiableKeys.Buttons.kOk), action: {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:])
                        }
                        
                    }))
                }
                
                return resultAlert
                
            }) //: alert
            .sheet(isPresented: $model.openSheet, content: {
                
                switch model.showSheetTypes {
                
                case IdentifiableKeys.sheetTypes.kOpenGallary:
                    ImagePicker(sourceType: .photoLibrary, imageUrl: $imageURL, Image: $inputImage, sendImageURL: $imageStringWithToken)
                case IdentifiableKeys.sheetTypes.kOpenAddList:
                    if !isGroupChat {
                        
                        GroupChatView(GroupVM: GroupChatViewModel(), selectedUser: userObj, isFormGroupChat: false, isFromGroupList: false)
                        
                    } else {
                        
                        GroupChatView(GroupVM: GroupChatViewModel(), selectedGroup: groupOBJ, isFormGroupChat: true, isFromGroupList: false)
                    }
                case IdentifiableKeys.sheetTypes.kOpenDeleteList:
                    DeleteUserListView(groupModel: groupOBJ)
                case IdentifiableKeys.sheetTypes.kOpenUsersList:
                    GroupUserList(groupListVM: GroupUserListViewModel(), groupModel: groupOBJ)
                case IdentifiableKeys.sheetTypes.kOpenForwardList:
                    ForwardMessageView(selectedMessage: model.selectedMessage, chatUsersID: model.chatUserID, isFromGroup: model.isFromGroup)
                default:
                    ImagePicker(sourceType: .camera, imageUrl: $imageURL, Image: $inputImage, sendImageURL: $imageStringWithToken)
                }
                
                
                
            })//: Sheet
            .onAppear(perform: {
                
                IQKeyboardManager.shared.enable = false
                
                NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NSNotification.Name.RawValue("update usermodel")), object: nil, queue: .main) { (notification) in
                    
                    DispatchQueue.main.async {
                        
                        self.groupOBJ = SwiftUIChatApp.sharedInstance.updatedGroupData
                    }
                    
                }
                
                if !isGroupChat {
                    guard let userModel = userObj else {
                        return
                    }
                    model.fetchMessagesFormCollection(senderID: UserModel.getCurrentUserID(), receriverID: userModel.uID) { (success) in
                        print(success)
                    }
                    
                } else {
                    guard let groupModel = groupOBJ else {
                        return
                    }
                    model.fetchMessagesForGroupCollcetion(GroupID: groupModel.groupID) { (sucess) in
                        print(sucess)
                        
                        if sucess {
                            
                            model.getAdminName(AdminID: groupModel.admin)
                            
                        }
                        
                    }
                    
                    
                }
                
            })//: onapper
            .hideNavigationBar()
            .navigationBarBackButtonHidden(true)
        }
        
        
    }
}


//MARK: - Preview
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(isGroupChat: false)
            .previewDevice("iPhone 11")
    }
}
