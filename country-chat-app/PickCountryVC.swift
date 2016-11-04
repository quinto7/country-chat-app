//
//  PickCountryVC.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 1/11/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class PickCountryVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var countryTextField: RoundTextField!
    
    var countryArray = [String]()
    var pickerView: UIPickerView!
    var user: User!
    var chatFunctions = ChatFunctions()
    var selectedUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        countryTextField.inputView = pickerView
        
        //Para hacer una lista de paises para usar despues
        for code in Locale.isoRegionCodes as [String]{
            let id = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue : code])
            let name = (Locale(identifier: "en_EN") as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code \(code)"
            countryArray.append(name)
            countryArray.sort(by: { (name1, name2) -> Bool in
                
                name1 < name2
            })
        }
        
        //Extensions para hacer desaparecer el keyboard
        self.hideKeyboardWhenTappedAround()
        self.hideKeyboardWhenSwipeDown()
    }

    @IBAction func continueBtnPressed(_ sender: AnyObject) {
        
        if let choosenCountry = countryTextField.text, (choosenCountry.characters.count > 0){
            
            //Recuperar los paises de todos los usuarios
//            databaseRef.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
//                
//                if let users = snapshot.value as? Dictionary<String, AnyObject>{
//                    for (key, value) in users{
//                        if let dict = value as? Dictionary<String, AnyObject>{
//                            let userUid = dict["uid"] as! String
//                            let username = dict["username"] as! String
//                            let profileImage = dict["profileImageUrl"] as! String
//                            if let country = dict["country"] as? String{
//                                let uid = key
//                                
//                                if choosenCountry == country{
//                                    
//                                    if uid != FIRAuth.auth()!.currentUser!.uid{
//                                        
//                                                            
//                                    //Como hacer para que solo se cree un CHAT. Al ser un for loop se crean todos los chats que tienen el pais elejido.
//                                                            
//                                        let currentUser = User(username: FIRAuth.auth()!.currentUser!.displayName!, userId: FIRAuth.auth()!.currentUser!.uid, profileImageUrl: String(describing: FIRAuth.auth()!.currentUser!.photoURL!))
//                                        let otherUser = User(username: username, userId: userUid, profileImageUrl: profileImage)
//                                                            
//                                        self.chatFunctions.startChat(user1: currentUser, user2: otherUser)
//                                                            
//                                                            
//                                                            
//                                    }else{
//                                        print("Same user avoid. Choosen: \(choosenCountry), \(username)  country:\(country)")
//                                    }
//                                    
//                                    
//                                }else{
//                                    
//                                    print("Don't match. Choosen: \(choosenCountry), \(username)  country:\(country)")
//                                }
//                                
//                            }
//                        }
//                    }
//                    
//                    
//                        
//                    
//                    
//                    
//                    
//                }
//                
//                
//                
//                
//                
//                }, withCancel: { (error) in
//                    
//                    print(error.localizedDescription)
//            })
            
           
            
            databaseRef.child("users").queryOrdered(byChild: "country").queryEqual(toValue: choosenCountry).observeSingleEvent(of: .value, with: { (snapshot) in
                
                for user in snapshot.children{
                    
                    let newUser = User(snapshot: user as! FIRDataSnapshot)
                    
                    //Compruebo para que no aparezca el usuario q esta loggeado
                    if newUser.uid != FIRAuth.auth()!.currentUser!.uid{
                        //Se agregan todos los usuarios con el pais seleccionado
                        self.selectedUsers.append(newUser)
                        
                    }
                    
                }
                
                let randomNumber = Int(arc4random_uniform(UInt32(self.selectedUsers.count)))
                print(randomNumber)
                
                let randomUser = self.selectedUsers[randomNumber]
                self.selectedUsers.remove(at: randomNumber)
                
                let currentUser = User(username: FIRAuth.auth()!.currentUser!.displayName!, userId: FIRAuth.auth()!.currentUser!.uid, profileImageUrl: String(describing: FIRAuth.auth()!.currentUser!.photoURL!))
                let otherUser = User(username: randomUser.username, userId: randomUser.uid, profileImageUrl: randomUser.profileImageUrl)
                
                self.chatFunctions.startChat(user1: currentUser, user2: otherUser)
                
                
                }, withCancel: { (error) in
                    
                    print(error.localizedDescription)
            })
            
            
            
            
            
            
            
            //Preform segue to ChatVC
            
        }else{
            print("No country selected")
        }
        
        
        self.resignAllFirstResponder()
        
        
        
    }
    
    // MARK: - PickerView
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryTextField.text = countryArray[row]
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryArray.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func dismissPickerView(_ gesture: UITapGestureRecognizer){
        self.view.endEditing(true)
        
    }
    
    //MARK: Keyboard
    
    //To dismiss picker and keyboard when button pressed
    func resignAllFirstResponder(){
        
        countryTextField.resignFirstResponder()
       
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
