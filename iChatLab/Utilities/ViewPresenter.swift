//
//  ViewPresenter.swift
//  iChatLab
//
//  Created by Han Luong on 3/20/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import Foundation
import UIKit

class ViewPresenter {
    public static func changeRootView(by viewController: UIViewController, duration: TimeInterval = 0.5, options: UIView.AnimationOptions = .transitionCrossDissolve, completion: ((Bool) -> Void)? = nil) {
        guard let window = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
            .filter({$0.isKeyWindow}).first else { return }
        guard let rootViewController = window.rootViewController else { return }
        viewController.view.frame = rootViewController.view.frame
        viewController.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: duration, options: options, animations: {
            window.rootViewController = viewController
        }, completion: completion)
    }
}
