//
//  SignInVC.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 18/9/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit

class SignInVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var signUpBtn: RoundedButton!
    @IBOutlet weak var chosseImgBtn: UIButton!
    @IBOutlet weak var countryTxtFld: RoundTextField!
    @IBOutlet weak var passwordTxtFld: RoundTextField!
    @IBOutlet weak var emailTxtFld: RoundTextField!
    @IBOutlet weak var usernameTxtFld: RoundTextField!
    @IBOutlet weak var profileImageView: RoundedImageView!
    
    var imagepicker: UIImagePickerController!
    var pickerView: UIPickerView!
    
    var countryArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagepicker = UIImagePickerController()
        imagepicker.delegate = self
        imagepicker.allowsEditing = true
        
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        countryTxtFld.inputView = pickerView
        
        //Para hacer una lista de paises para usar despues
        for code in Locale.isoRegionCodes as [String]{
            let id = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue : code])
            let name = (Locale(identifier: "en_EN") as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code \(code)"
            countryArray.append(name)
            countryArray.sort(by: { (name1, name2) -> Bool in
                
                name1 < name2
            })
        }
        
        //Tap gesture para hacer desparecer el PickerView cuando se apretea afuera
        
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPickerView(_:)))
//        tapGestureRecognizer.numberOfTapsRequired = 1
//        self.view.addGestureRecognizer(tapGestureRecognizer)
//        
        
        
        //Extensions para hacer desaparecer el keyboard
        self.hideKeyboardWhenTappedAround()
        self.hideKeyboardWhenSwipeDown()


    }

    @IBAction func chosseImgBtnPressed(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Add a Picture", message: "Choose from", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            
            self.imagepicker.sourceType = .camera
            self.present(self.imagepicker, animated: true, completion: nil)
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            
            self.imagepicker.sourceType = .photoLibrary
            self.present(self.imagepicker, animated: true, completion: nil)
        }
        let photoAlbumAction = UIAlertAction(title: "Saved Photo Album", style: .default) { (action) in
            
            self.imagepicker.sourceType = .savedPhotosAlbum
            self.present(self.imagepicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(photoAlbumAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func signinBtnPressed(_ sender: AnyObject) {
        
        let email = emailTxtFld.text?.lowercased()
        let finalEmail = email?.trimmingCharacters(in: CharacterSet.whitespaces)
        let data = UIImageJPEGRepresentation(profileImageView.image!, 0.2)
        
        //TODO: Create a way to prevent to users haveing the same username
        if let email = finalEmail, let password = passwordTxtFld.text, let country = countryTxtFld.text, let username = usernameTxtFld.text , (email.characters.count > 0 && password.characters.count > 0 && country.characters.count > 0 && username.characters.count > 0){
            
            
            AuthService.instance.SignIn(email: email, username: username, password: password, country: country, data: data!)
            
            self.resignAllFirstResponder()

            
        }else{
            
            //Error handlings ->AlertControllers
            let alert = UIAlertController(title: "Use a valid email and password", message: "You must enter valid username and password", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
            
        }
        
        
        
    }
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        
    }
    
    
    //MARK: Picker View Methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryTxtFld.text = countryArray[row]
        
        
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
    
    //To dismiss picker and keyboard when button pressed
    
    func resignAllFirstResponder(){
    
        countryTxtFld.resignFirstResponder()
        emailTxtFld.resignFirstResponder()
        passwordTxtFld.resignFirstResponder()
        usernameTxtFld.resignFirstResponder()
    
    }
    
    //MARK: ImagePicker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.profileImageView.image = image
        }

        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //MARK: Keyboard
    

    


}
