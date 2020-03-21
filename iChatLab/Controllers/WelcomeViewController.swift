//
//  WelcomeViewController.swift
//  iChatLab
//
//  Created by Han Luong on 3/19/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: - Helpers function
    private func setupUI() {
        loginButton.styleFilledButton()
        registerButton.styleHollowButton()
    }
    
    @IBAction func unwindToWelcome(_ sender: UIStoryboardSegue){}
}
