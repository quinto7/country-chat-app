//
//  ViewController.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 18/9/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordTxtFld: RoundTextField!
    @IBOutlet weak var emailTxtFld: RoundTextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTxtFld.delegate = self
        passwordTxtFld.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        self.hideKeyboardWhenSwipeDown()
       
        
    }

    @IBAction func loginBtnPressed(_ sender: AnyObject) {
        
        //Para sacar todo espacio en blanco que pueda poner el usuario en el textfield
        let email = emailTxtFld.text?.lowercased()
        let finalEmail = email?.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if let email = finalEmail, let password = passwordTxtFld.text , (email.characters.count > 0 && password.characters.count > 0){
            
            AuthService.instance.emailLogin(email: email, password: password) { (errMessage, data) in
                
                
                guard errMessage == nil else{
                    
                    let alertController = UIAlertController(title: "Error Authetication", message: errMessage, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                    
                }
                
                self.resignAllFirstResponder()
            
            }
        }else{
            //Error: email or password empty
            let alert = UIAlertController(title: "Username and Password Requiered", message: "You must enter both username and password", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
            
        }
        
    }
    
    @IBAction func signupBtnPressed(_ sender: AnyObject) {
        
    }
    
    //To dismiss picker and keyboard when button pressed
    
    func resignAllFirstResponder(){
        
        emailTxtFld.resignFirstResponder()
        passwordTxtFld.resignFirstResponder()
        
    }
    

}

