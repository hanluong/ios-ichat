//
//  LoginViewController.swift
//  iChatLab
//
//  Created by Han Luong on 3/19/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - Vars
    private let dbService = DatabaseService.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    // MARK: - Helper functions
    private func setupUI() {
        emailTextField.styleTextField()
        passwordTextField.styleTextField()
        loginButton.styleFilledButton()
    }
    
    
    private func loginUser(email: String, password: String) {
        ProgressHUD.show("Login ...")
        self.dbService.loginUserWith(email: email, password: password) { error in
            if let error = error {
                ProgressHUD.dismiss()
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            self.gotoApp()
        }
    }
    
    private func gotoApp() {
        ProgressHUD.dismiss()
        self.clearAllTextFields()
        self.dismissKeyboard()
        
        // TODO: gotoAPP
        ViewPresenter.changeRootView(by: Storyboard.mainView)
    }
    
    private func clearAllTextFields() {
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - IBActions
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let email = emailTextField.text, emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            ProgressHUD.showError("Email is missing")
            return
        }
        guard let password = passwordTextField.text, passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            ProgressHUD.showError("Password is missing")
            return
        }
        self.loginUser(email: email, password: password)
    }
}
