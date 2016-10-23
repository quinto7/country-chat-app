//
//  AuthService.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 18/9/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import UIKit

typealias Completion = (_ errmessage: String?, _ data: AnyObject?) -> Void

class AuthService{
    
    private static let _instance = AuthService()
    
    static var instance:AuthService{
        return _instance
    }
    
    //TODO: HANDLING ERRORS WHEN CREATING A NEW USER
    
    func emailLogin(email: String, password: String, onComplete:Completion?){
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if let error = error as? NSError, let firebaseError = FIRAuthErrorCode(rawValue: error.code){
                
                switch firebaseError{
                case .errorCodeUserNotFound:
                    self.handleFirebaseError(error: error, onComplete: onComplete!)
                    break
        
                default:
                    self.handleFirebaseError(error: error, onComplete: onComplete!)
                    break
                }
                
            }else{
                
                //Login
                let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDel.logUser()
                print("User \(user?.displayName) has login successfully")
                onComplete?(nil, user)
                
            }
        })
        
        
    }
    //1 -- Create user
    
    func SignIn(email: String, username: String, password:String, country:String, data:Data){
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error == nil{
                
                self.setUserInfo(user: user!, username: username, password: password, country: country, data: data)
                
            }else{
                
                print(error?.localizedDescription)
                
            }
            
        })
        
    }
    
    //2 -- Save the user Info: Profile pic
    private func setUserInfo(user:FIRUser, username:String, password:String, country:String, data:Data){
        
        let imagePath = "profilePic\(user.uid)/userPic.jpg"
        let imageRef = storageRef.child(imagePath)
        
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        
        imageRef.put(data as Data, metadata: metaData) { (metadata, error) in
            
            if error == nil{
                
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = username
                
                if let imageUrl = metadata?.downloadURL(){
                    changeRequest.photoURL = imageUrl
                }
                
                changeRequest.commitChanges(completion: { (error) in
                    
                    if error == nil{
                        
                        //SaveInfo
                        self.saveUserInfo(user: user, username: username, password: password, country: country)
                        
                    }else{
                        print(error?.localizedDescription)
                    }
                })
                
            }else{
                print(error?.localizedDescription)
            }
        }
        
    }
    
    //3 -- Save userInfo en database
    func saveUserInfo(user:FIRUser!, username:String, password:String, country:String){
        
        let userInfo = ["email": user.email!, "username": username, "country": country, "uid": user.uid, "profileImageUrl": String(describing: user.photoURL!)] as [String: Any]
        
        let userRef = databaseRef.child("users").child(user.uid)
        userRef.setValue(userInfo)
        
        //LogIn after createing new user
        emailLogin(email: user.email!, password: password, onComplete: nil)
        print("User: \(user.displayName) has created a new account successfully")
        
        
    }
    
    func handleFirebaseError(error:NSError, onComplete: Completion){
        print(error.debugDescription)
        if let errorCode = FIRAuthErrorCode(rawValue: error.code){
            switch errorCode {
            case .errorCodeInvalidEmail:
                onComplete("Invalid email address. If you don't have an account create one!", nil)
                break
            case .errorCodeWrongPassword:
                onComplete("Invalid password", nil)
                break
            case .errorCodeEmailAlreadyInUse, .errorCodeAccountExistsWithDifferentCredential:
                onComplete("Email already in use", nil)
                break
            case .errorCodeWeakPassword:
                onComplete("Password is to weak. Please change it", nil)
                break
            default:
                onComplete("There was a problem authenicating. Try Again", nil)
            }
        }
    }
    
    
}
