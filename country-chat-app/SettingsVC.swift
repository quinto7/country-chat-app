//
//  SettingsVC.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 23/10/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SettingsVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    func deleteAccount(){
        
        let alertController = UIAlertController(title: "Delete Account?", message: "Are you sure you wanna delete your account?", preferredStyle: .alert)
        let actionNo = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let actionYes = UIAlertAction(title: "Yes", style: .destructive) { (alertAction) in
            
            //TODO: El usuario se tiene que loggear de nuuevo para poder eliminar la cuenta. Agregar un handler que permita logearse de nuevo (un view controller). Usar: reauthenticateWithCredential
            
            let currentUserRef = databaseRef.child("users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
            currentUserRef.observe(.value, with: { (snapshot) in
                
                for user in snapshot.children {
                    
                    let currentUser = User(snapshot: user as! FIRDataSnapshot)
                    currentUser.ref?.removeValue(completionBlock: { (error, ref) in
                        
                        if error == nil{
                            
                            FIRAuth.auth()!.currentUser!.delete(completion: { (error) in
                                
                                if error == nil{
                                    print("Account was successfully deleted")
                                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginScreen") as! LoginVC
                                    self.present(vc, animated: true, completion: nil)
                                }else{
                                    print(error!.localizedDescription)
                                }
                            })
                            
                        }else{
                            
                            print(error!.localizedDescription)
                        }
                    })
                }
                
                
            }) { (error) in
                
                print(error.localizedDescription)
            }
            
        }
        
        alertController.addAction(actionNo)
        alertController.addAction(actionYes)
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    func resetPassword(email: String){
        
        let waringAlertController = UIAlertController(title: "Reset Password?", message: "Are you sure you want to reset your password?", preferredStyle: .alert)
        let actionNo = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let actionYes = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            
            FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
                
                if error == nil{
                    
                    let alercontroller = UIAlertController(title: "Reset Password", message: "An email has been sent to \(email) to reset your password", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alercontroller.addAction(action)
                    print("Email sent")
                    self.present(alercontroller, animated: true, completion: nil)
                    
                    
                }else{
                    
                    print(error!.localizedDescription)
                }
            })
            
        }
        
        waringAlertController.addAction(actionYes)
        waringAlertController.addAction(actionNo)
        
        self.present(waringAlertController, animated: true, completion: nil)
        
    }
    
    
    
    //MARK: TableView
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0{
            deleteAccount()
        }else if indexPath.section == 1 && indexPath.row == 1{
            let email = FIRAuth.auth()!.currentUser!.email!
            resetPassword(email: email)
        }
        
    }
}
