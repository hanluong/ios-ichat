//
//  RegisterViewController.swift
//  iChatLab
//
//  Created by Han Luong on 3/12/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit
import ProgressHUD

class RegisterViewController: UIViewController {
    
    // MARK: - Vars
    private let dbService = DatabaseService.instance
    
    // MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupUI() {
        emailTextField.styleTextField()
        passwordTextField.styleTextField()
        repeatPasswordTextField.styleTextField()
        registerButton.styleFilledButton()
    }
    
    // MARK: - IBActions
    @IBAction func registerButtonPressed(_ sender: Any) {
        guard emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            ProgressHUD.showError("Email is missing")
            return
        }
        guard let password = passwordTextField.text, passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            ProgressHUD.showError("Password is missing")
            return
        }
        guard let repeatPassword = repeatPasswordTextField.text, repeatPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            ProgressHUD.showError("Repeat password is missing")
            return
        }
        
        if password == repeatPassword {
            registerUser()
        } else {
            ProgressHUD.showError("Password and Repeat password do NOT match")
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.Identifier.Segue.goTiFinishedRegisterVC {
            let vc = segue.destination as! FinishedRegisterViewController
            vc.email = emailTextField.text!
            vc.password = passwordTextField.text!
        }
    }
    
    // MARK: - Helpers function
    private func registerUser() {
        self.clearAllTextFields()
        self.dismissKeyboard()
        performSegue(withIdentifier: Storyboard.Identifier.Segue.goTiFinishedRegisterVC, sender: nil)
    }
    
    private func clearAllTextFields() {
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        self.repeatPasswordTextField.text = ""
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
