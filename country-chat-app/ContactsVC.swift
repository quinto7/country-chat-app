//
//  ContactsVC.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 30/9/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class ContactsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView:UITableView!
    
    var usersArray = [User]()
    var chatFunctions = ChatFunctions()   //Para ejecutar las funcs del model
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        loadUsers()
    }
    
    func loadUsers(){
        
        databaseRef.child("users").observe(.value, with: { (snapshot) in
            
            var allUsers = [User]()
            
            for user in snapshot.children{
                let newUser = User(snapshot: user as! FIRDataSnapshot)
                
                //Compruebo para que no aparezca el usuario q esta loggeado
                if newUser.uid != FIRAuth.auth()!.currentUser!.uid{
                    
                    allUsers.append(newUser)

                }
            }
            self.usersArray = allUsers.sorted(by: { (user1, user2) -> Bool in
                
                user1.username < user2.username
            })
            
            self.tableView.reloadData()
            
            
            }) { (error) in
                
                print(error.localizedDescription)
        }
        
    }
    

    //MARK: TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Creo un nuevo chatId en firebase si no existe y se existe solo se abre
        let currentUser = User(username: FIRAuth.auth()!.currentUser!.displayName!, userId: FIRAuth.auth()!.currentUser!.uid, profileImageUrl: String(describing: FIRAuth.auth()!.currentUser!.photoURL!))
        chatFunctions.startChat(user1: currentUser, user2: usersArray[indexPath.row])
        
        performSegue(withIdentifier: "ChatVC", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "contactsCell") as? ContactsCell{
            configureCell(cell: cell, indePath: indexPath, usersArray: usersArray)
            
            return cell
        }else{
            
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
    
    private func configureCell(cell: ContactsCell, indePath: IndexPath, usersArray:[User]){
        
        cell.usernameLbl.text = usersArray[indePath.row].username
        cell.countryLbl.text = usersArray[indePath.row].country
        
        FIRStorage.storage().reference(forURL: usersArray[indePath.row].profileImageUrl).data(withMaxSize: 1 * 1024 * 1024) { (imgData, error) in
            
            if let error = error{
                print(error.localizedDescription)
            }else{
                DispatchQueue.main.async {
                    if let data = imgData{
                        cell.userImage.image = UIImage(data: data)
                    }
                    
                }
            }
        }
    }
    
    //MARK: Segue Method
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ChatVC"{
            
            if let chatVC = segue.destination as? ChatVC{
                
                chatVC.senderId = FIRAuth.auth()!.currentUser!.uid
                chatVC.senderDisplayName = FIRAuth.auth()!.currentUser!.displayName
                chatVC.chatRoomId = chatFunctions.chatRoom_Id
                
            }
            
        }
        
    }
    
    
    
    
    
    
    
    
    

}
