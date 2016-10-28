//
//  EditProfileVC.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 23/10/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

//EL MAIL NO SE EDITA

class EditProfileVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var profileImage: RoundedImageView!
    @IBOutlet weak var usernameTxtFld: UITextField!
    @IBOutlet weak var emailTxtFld: UITextField!
    
    var imagepicker: UIImagePickerController!
    var user:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagepicker = UIImagePickerController()
        imagepicker.delegate = self
        
        //Para que desaparezca el teclado cuando apreto return
        emailTxtFld.delegate = self
        usernameTxtFld.delegate = self
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(EditProfileVC.chosseImage))
        imageTapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(imageTapGesture)
        profileImage.isUserInteractionEnabled = true
        

        self.hideKeyboardWhenTappedAround()
        self.hideKeyboardWhenSwipeDown()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        fetchCurrentUserInfo()
    }

    @IBAction func saveBtnPressed(_ sender: AnyObject) {
        
        let email = emailTxtFld.text?.lowercased()
        let finalEmail = email?.trimmingCharacters(in: CharacterSet.whitespaces)
        let data = UIImageJPEGRepresentation(profileImage.image!, 0.2)!
        
        //TODO: Create a way to prevent to users haveing the same username
        if let email = finalEmail, let username = usernameTxtFld.text,(email.characters.count > 0  && username.characters.count > 0){
            
            let imagePath = "profilePic\(user.uid)/userPic.jpg"
            let imageRef = storageRef.child(imagePath)
            
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            
            imageRef.put(data as Data, metadata: metaData) { (metadata, error) in
                
                if error == nil{
                    
                    //Update Email
                    FIRAuth.auth()!.currentUser!.updateEmail(email, completion: { (error) in
                        if error == nil{
                            print("Updated Email: \(email)")
                        }else{
                            print(error!.localizedDescription)
                        }
                        
                    })
                    
                    let changeRequest = FIRAuth.auth()!.currentUser!.profileChangeRequest()
                    changeRequest.displayName = username
                    
                    if let imageUrl = metadata!.downloadURL(){
                        changeRequest.photoURL = imageUrl
                    }
                    
                    changeRequest.commitChanges(completion: { (error) in
                        
                        if error == nil{
                            
                            //SaveInfo in firebase
                            let user = FIRAuth.auth()!.currentUser!
                            
                            let userInfo = ["email": user.email!, "username": username,"uid": user.uid, "profileImageUrl": String(describing: user.photoURL!)] as [String: Any]
                            
                            let userRef = databaseRef.child("users").child(user.uid)
                            userRef.setValue(userInfo, withCompletionBlock: { (error, ref) in
                                
                                if error == nil{
                                    self.navigationController!.popToRootViewController(animated: true)
                                    print("Profile was edited: Username:\(username)")

                                }else{
                                    print(error!.localizedDescription)
                                }
                            })
                            
                            
                        }else{
                            print(error!.localizedDescription)
                        }
                    })
                    
                }else{
                    print(error!.localizedDescription)
                }
            }
            
            
        }else{
            
            //Error handlings ->AlertControllers
            let alert = UIAlertController(title: "Use a valid email and password", message: "You must enter valid username and password", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
        }

    }
    
    func chosseImage() {
        
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
    
    func fetchCurrentUserInfo(){
        databaseRef.child("users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            for userInfo in snapshot.children{
                self.user = User(snapshot: userInfo as! FIRDataSnapshot)
            }
            
            
            if let user = self.user{
                
                self.usernameTxtFld.text = user.username
                self.emailTxtFld.text = user.email
                
                
            }
            
        }) { (error) in
            
            print(error.localizedDescription)
        }

    }
    
    //MARK: TableView
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0{
            self.chosseImage()
            
        }
        
    }

    //MARK: ImagePicker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.profileImage.image = image
        }
        
        
        self.dismiss(animated: true, completion: nil)
    }

    //MARK: Keyboard
    
    //To dismiss keyboard with return button
    func textFieldShouldReturn(_ textField:UITextField)-> Bool{
        emailTxtFld.resignFirstResponder()
        usernameTxtFld.resignFirstResponder()
        
        return true
    }
}
