//
//  ImagePickerView.swift
//  ViewRepresentable
//
//  Created by differenz147 on 07/07/21.
//

import Foundation
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    
    //MARK: - TypeAlias
    typealias UIViewControllerType = UIImagePickerController
    
    //MARK: - Variable
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var imageUrl:URL?
    @Binding var Image:UIImage?
    @Binding var sendImageURL:String
    var storageVM = firebaseStorageViewModel()
    
    //MARK: - Environment variable
    @Environment(\.presentationMode) var presentationMode
   
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerView = UIImagePickerController()
        imagePickerView.mediaTypes = ["public.image"]
        imagePickerView.sourceType = sourceType
        imagePickerView.allowsEditing = true
        imagePickerView.delegate = context.coordinator
        return imagePickerView
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    
}

//MARK: - coOrdinate imagePicker
extension ImagePicker {
    
    class Coordinator: NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.Image = uiImage
            }
            
            let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL
            parent.imageUrl = imageURL
            
            parent.presentationMode.wrappedValue.dismiss()
            
            
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
    }
}
