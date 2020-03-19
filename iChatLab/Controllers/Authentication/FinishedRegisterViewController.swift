//
//  FinishedRegisterViewController.swift
//  iChatLab
//
//  Created by Han Luong on 3/12/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit
import ProgressHUD
import ImagePicker

class FinishedRegisterViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    // MARK: - Vars
    private let dbService = DatabaseService.instance
    var email: String!
    var password: String!
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatarImageView.isUserInteractionEnabled = true
    }
    
    // MARK: - IBActions
    @IBAction func avatarImageTapped(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        
        present(imagePickerController, animated: true, completion: nil)
        dismissKeyboard()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismissKeyboard()
        clearAllTextFields()
        
        // TODO: cancel action
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismissKeyboard()
        ProgressHUD.show("Registering ...")
        guard let firstName = nameTextField.text, nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            ProgressHUD.showError("Name is missing")
            return
        }
        guard let lastName = surnameTextField.text, surnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            ProgressHUD.showError("Surname is missing")
            return
        }
        guard let country = countryTextField.text, countryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            ProgressHUD.showError("Country is missing")
            return
        }
        guard let city = cityTextField.text, cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            ProgressHUD.showError("City is missing")
            return
        }
        guard let phone = phoneTextField.text, phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            ProgressHUD.showError("Phone is missing")
            return
        }
        dbService.registerUserWith(email: email, password: password) { (error) in
            if let error = error {
                ProgressHUD.dismiss()
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            
            // TODO:
            // - get avatarImage or auto generate it
            // - create final userInfoDict
            // - finishedRegistration
            if self.avatarImage == nil {
                Common.generateImageFromUserName(firstName: firstName, lastName: lastName) { (image) in
                    self.avatarImage = image
                }
            }
            let avatarData = self.avatarImage!.jpegData(compressionQuality: 0.7)
            let avatarEncodedString = avatarData!.base64EncodedString(options: .init(rawValue: 0))
            
            let userInfoDict: [String:Any] = [
                kFIRST_NAME: firstName,
                kLAST_NAME: lastName,
                kFULL_NAME: firstName + " " + lastName,
                kAVATAR: avatarEncodedString,
                kCOUNTRY: country,
                kCITY: city,
                kPHONE: phone
            ]
            self.finishedRegistration(withValue: userInfoDict)
        }
    }
    
    // MARK: - Helpers function
    private func finishedRegistration(withValue: [String:Any]) {
        //TODO:
        // - Update current user in firestore
        // - Goto app
        dbService.updateCurrentUserInFirestore(withValue: withValue) { error in
            if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                return
            }
            self.gotoApp()
        }
    }
    
    private func gotoApp() {
        ProgressHUD.dismiss()
        dismissKeyboard()
        clearAllTextFields()
        
        present(Storyboard.mainView, animated: true, completion: nil)
    }
    
    private func clearAllTextFields() {
        nameTextField.text = ""
        surnameTextField.text = ""
        countryTextField.text = ""
        cityTextField.text = ""
        phoneTextField.text = ""
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

// MARK: - ImagePickerDelegate
extension FinishedRegisterViewController: ImagePickerDelegate {
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if images.count > 0 {
            self.avatarImage = images.first!
            self.avatarImageView.image = self.avatarImage
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
