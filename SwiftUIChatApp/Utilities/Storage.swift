//
//  Storage.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 23/07/21.
//

import Foundation

struct folderName {
    
    static let kImagesFolder = "images"
    static let kSharedFolder = "shared"
}


class firebaseStorageViewModel: NSObject,ObservableObject {
    
    
    @Published var showLoader:Bool = false
    
    
    
}

//MARK: - Helper method
extension firebaseStorageViewModel {
    
    /// upload file to firebase storage
    func uploadFile(folderName:String = "images",image: UIImage? = nil,fileURL: URL? ,completion: @escaping (_ success:Bool,_ imageUrl:String) -> Void){
        
        var imageURL = String()
        
        do {
            
            let uniqueString = UUID().uuidString
            
            let fileName = "\(uniqueString)"
            
            let fileStoragePath = Storage.storage().reference().child(folderName).child(fileName)
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/png"
            var imageData = Data()
            
            if fileURL != nil {
                
                imageData = try Data(contentsOf: fileURL!)
                
            } else {
                print()
                imageData = (image?.pngData())!
                
            }
            
           
            
           
            
            self.showLoader = true
            
            fileStoragePath.putData(imageData, metadata: metaData) { (StorageMetadata, error) in
                
                if error != nil {
                    print(error?.localizedDescription ?? "unable to upload data")
                    self.showLoader = false
                    completion(false, error?.localizedDescription ?? "error")
                } else {
                    
                    fileStoragePath.downloadURL { (url, error) in
                        
                        if error != nil {
                            self.showLoader = false
                            print(error?.localizedDescription ?? "error occur while getting image storage url")
                            completion(false, error?.localizedDescription ?? "error")
                        } else {
                            self.showLoader = false
                            imageURL = url!.absoluteString
                            print(imageURL as Any )
                            completion(true, imageURL)
                        }
                        
                    }
                    
                }
                
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    /// delete file form firebase storage
    func deleteFile(fileURL: String,completion: @escaping (Bool) -> Void) {
        
        let fileStoragePath = Storage.storage().reference(forURL: fileURL)
        self.showLoader = true
        fileStoragePath.delete { (error) in
            
            if error != nil {
                self.showLoader = false
                print(error?.localizedDescription ?? "error occur while deleting image ")
                completion(false)
            } else {
                self.showLoader = false
                completion(true)
            }
            
        }
        
    }
    
    
    
}
