//
//  MyProfileVC.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 21/9/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class MyProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var profileImage: RoundedImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var countryLbl: UILabel!
    
    var user:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        databaseRef.child("users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            for userInfo in snapshot.children{
                self.user = User(snapshot: userInfo as! FIRDataSnapshot)
            }
            
            
            if let user = self.user{
                
                self.usernameLbl.text = user.username
                self.countryLbl.text = user.country
                
                
                FIRStorage.storage().reference(forURL: user.profileImageUrl).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                    
                    if let error = error{
                        print(error.localizedDescription)
                    }else{
                        
                        DispatchQueue.main.async {
                            if let data = imgData{
                                self.profileImage.image = UIImage(data: data)
                            }
                            
                        }
                    }
                })
            }
            
        }) { (error) in
            
            print(error.localizedDescription)
        }
    }

    @IBAction func signOutBtnPressed(sender:UIBarButtonItem){
        
        do {
            try FIRAuth.auth()!.signOut()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LoginScreen")
            present(controller, animated: true, completion: nil)
            
            print("User logged out")
            
        }catch let error{
            
            print(error.localizedDescription)
            
        }
    }
    
    //MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    //TODO: Hacer funcionar la tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            if let emailCell = tableView.dequeueReusableCell(withIdentifier: "emailCell"){
                emailCell.detailTextLabel?.text = FIRAuth.auth()!.currentUser!.email
                
                return emailCell
            }
            
        }else if indexPath.row == 1{
            let passCell = tableView.dequeueReusableCell(withIdentifier: "passCell")
            
            return passCell!
            
        }else{
            
            return UITableViewCell()
        }
        
        return UITableViewCell()
    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}
