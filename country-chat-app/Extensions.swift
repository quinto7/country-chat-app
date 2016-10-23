//
//  Extensions.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 23/9/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func hideKeyboardWhenSwipeDown(){
        let swipDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        swipDown.direction = .down
        view.addGestureRecognizer(swipDown)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
}

