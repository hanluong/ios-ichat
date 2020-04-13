//
//  Camera.swift
//  iChatLab
//
//  Created by Han Luong on 4/9/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

class Camera {
    
    var delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate
    
    init(delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
        self.delegate = delegate
    }
    
    func presentPhotoLibrary(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) && !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            return
        }
        
        let type = kUTTypeImage as String
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            if let availabelTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
                if availabelTypes.contains(type) {
                    imagePicker.mediaTypes = [type]
                }
            }
        } else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
                if availableTypes.contains(type) {
                    imagePicker.mediaTypes = [type]
                }
            }
        } else {
            return
        }
        imagePicker.allowsEditing = canEdit
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil)
    }
    
    func presentMultyCamera(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        let typeOne = kUTTypeImage as String
        let typeTwo = kUTTypeMovie as String
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if let availabelTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                if availabelTypes.contains(typeOne) {
                    imagePicker.mediaTypes = [typeOne, typeTwo]
                    imagePicker.sourceType = .camera
                }
            }
            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                imagePicker.cameraDevice = .rear
            }
            if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = .front
            }
        } else {
            return
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func presentPhotoCamera(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        let type = kUTTypeImage as String
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                if availableTypes.contains(type) {
                    imagePicker.mediaTypes = [type]
                    imagePicker.sourceType = .camera
                }
            }
            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                imagePicker.cameraDevice = .rear
            }
            if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = .front
            }
        }
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil)
    }
    
    func presentVideoCamera(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        let type = kUTTypeMovie as String
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if let availabelTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                if availabelTypes.contains(type) {
                    imagePicker.mediaTypes = [type]
                    imagePicker.sourceType = .camera
                    imagePicker.videoMaximumDuration = kMAX_DURATION
                }
            }
            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                imagePicker.cameraDevice = .rear
            }
            if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = .front
            }
        }
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil)
    }
    
    func presentVideoLibrary(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) && UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            return
        }
        
        let type = kUTTypeMovie as String
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
                if availableTypes.contains(type) {
                    imagePicker.mediaTypes = [type]
                }
            }
        } else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.sourceType = .savedPhotosAlbum
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
                if availableTypes.contains(type) {
                    imagePicker.mediaTypes = [type]
                }
            }
        }
        
        imagePicker.videoMaximumDuration = kMAX_DURATION
        imagePicker.allowsEditing = canEdit
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil)
        
    }
    
}


