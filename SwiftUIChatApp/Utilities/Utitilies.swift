//
//  Utitilies.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 23/07/21.
//

import Foundation
import Photos

class Utilities: NSObject {
    
    /// to check cemera permission
    class func checkCameraPermisson(compltion:@escaping(Bool) -> Void){
        
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            compltion(true)
            // Already Authorized
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    // User granted
                    compltion(true)
                } else {
                    compltion(false)
                    // User rejected
                }
            })
        }
    }
    
    /// to check photoLibrary Permission
    class func checkPhotoLibraryPermission(compltion:@escaping(Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            compltion(true)
        //handle authorized status
        case .denied, .restricted :
            compltion(false)
        //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    compltion(true)
                // as above
                case .denied, .restricted:
                    compltion(false)
                // as above
                case .notDetermined:
                    compltion(true)
                // won't happen but still
                case .limited:
                    compltion(true)
                @unknown default:
                    compltion(true)
                }
            }
        case .limited:
            compltion(true)
        @unknown default:
            compltion(true)
        }
    }
    
    
}
