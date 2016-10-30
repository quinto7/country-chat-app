//
//  ChatListVC.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 19/10/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SDWebImage

class ChatListVC: UITableViewController {

    var chatsArray = [ChatRoom]()
    var chatFunctions = ChatFunctions()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchChats()
        NotificationCenter.default.addObserver(self, selector: #selector(ChatListVC.fetchChats), name: NSNotification.Name(rawValue: "updateChats"), object: nil)
        
    }

    //Load chats from firebase
    func fetchChats(){
        
        chatsArray.removeAll(keepingCapacity: false)  //Para que no aparezca duplicado
        
        databaseRef.child("chatrooms").queryOrdered(byChild: "userId").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid).observe(.childAdded, with: { (snapshot) in
            
            let values = snapshot.value as! Dictionary<String, Any>
            
            let ref = snapshot.ref
            let key = snapshot.key
            let username = values["username"] as! String
            let otherUsername = values["otherUsername"] as! String
            let userId = values["userId"] as! String
            let otherUserId = values["otherUserId"] as! String
            let members = values["members"] as! [String]
            let chatRoomId = values["chatRoomId"] as! String
            let lastMessage = values["lastMessage"] as! String
            let userImageUrl = values["userImageUrl"] as! String
            let otherUserImageUrl = values["otherUserImageUrl"] as! String
            let timestamp = values["timestamp"] as! NSNumber
            
            var newChat = ChatRoom(username: username, otherUsername: otherUsername, userId: userId, otherUserId: otherUserId, members: members, chatRoomId: chatRoomId, lastMessage: lastMessage, userImageUrl: userImageUrl, otherUserImageUrl: otherUserImageUrl, timestamp: timestamp)
            newChat.ref = ref
            newChat.key = key
            
            if lastMessage == ""{
                //Eliminar chat vacio de firebase?
                print("chat no iniciado")
                
            }else{
                self.chatsArray.insert(newChat, at: 0)
                self.tableView.reloadData()
            }
            
        
            
            }) { (error) in
                
                print(error.localizedDescription)
                
        }
        
        databaseRef.child("chatrooms").queryOrdered(byChild: "otherUserId").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid).observe(.childAdded, with: { (snapshot) in
            
            let values = snapshot.value as! Dictionary<String, Any>
            
            let ref = snapshot.ref
            let key = snapshot.key
            let username = values["username"] as! String
            let otherUsername = values["otherUsername"] as! String
            let userId = values["userId"] as! String
            let otherUserId = values["otherUserId"] as! String
            let members = values["members"] as! [String]
            let chatRoomId = values["chatRoomId"] as! String
            let lastMessage = values["lastMessage"] as! String
            let userImageUrl = values["userImageUrl"] as! String
            let otherUserImageUrl = values["otherUserImageUrl"] as! String
            let timestamp = values["timestamp"] as! NSNumber
            
            var newChat = ChatRoom(username: username, otherUsername: otherUsername, userId: userId, otherUserId: otherUserId, members: members, chatRoomId: chatRoomId, lastMessage: lastMessage, userImageUrl: userImageUrl, otherUserImageUrl: otherUserImageUrl, timestamp: timestamp)
            newChat.ref = ref
            newChat.key = key
            
            if lastMessage == ""{
                
                
            }else{
                self.chatsArray.insert(newChat, at: 0)
                self.tableView.reloadData()
            }
            

            
        }) { (error) in
            
            print(error.localizedDescription)
            
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatCell

        var userPhotoUrlStr: String? = ""
        
        if chatsArray[indexPath.row].userId == FIRAuth.auth()!.currentUser!.uid{
            
            userPhotoUrlStr = chatsArray[indexPath.row].otherUserImageUrl
            cell.usernameLbl.text = chatsArray[indexPath.row].otherUsername
        }else{
            userPhotoUrlStr = chatsArray[indexPath.row].userImageUrl
            cell.usernameLbl.text = chatsArray[indexPath.row].username
        }
        
        //Seteamos el timestamp
        let oldDate = NSDate(timeIntervalSince1970: TimeInterval(chatsArray[indexPath.row].timestamp))
        let currentDate = NSDate()
        let calendar = NSCalendar.current
        
        let diffenceOfDate = calendar.dateComponents([.second, .minute, .hour, .day, .weekOfMonth], from: oldDate as Date, to: currentDate as Date)
        
        if diffenceOfDate.second! <= 0{
            cell.timeStamp.text = "now"
        }else if diffenceOfDate.second! > 0 && diffenceOfDate.minute! == 0{
            cell.timeStamp.text = "\(diffenceOfDate.second!)s"
        }else if diffenceOfDate.minute! > 0 && diffenceOfDate.hour! == 0{
            cell.timeStamp.text = "\(diffenceOfDate.minute!)m"
        }else if diffenceOfDate.hour! > 0 && diffenceOfDate.day! == 0{
            cell.timeStamp.text = "\(diffenceOfDate.hour!)h"
        }else if diffenceOfDate.day! > 0 && diffenceOfDate.weekOfMonth! == 0{
            cell.timeStamp.text = "\(diffenceOfDate.day!)d"
        }else if diffenceOfDate.weekOfMonth! > 0 {
            cell.timeStamp.text = "\(diffenceOfDate.weekOfMonth!)w"
        }
        
        
        cell.lastMessageLbl.text = chatsArray[indexPath.row].lastMessage
        
        if let urlString = userPhotoUrlStr{
            
            DispatchQueue.main.async{
                
                cell.userImage.sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named: "profile-placeholder"))
            }
            
//            FIRStorage.storage().reference(forURL: urlString).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
//                
//                if let error = error{
//                    print(error.localizedDescription)
//                }else{
//                    DispatchQueue.main.async{
//                        if let data = imgData{
//                            cell.userImage.image = UIImage(data: data)
//                        }
//                    }
//                }
//            })
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            self.chatsArray[indexPath.row].ref?.removeValue()
            self.chatsArray.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Creo un nuevo chatId en firebase si no existe y se existe solo se abre
        let currentUser = User(username: FIRAuth.auth()!.currentUser!.displayName!, userId: FIRAuth.auth()!.currentUser!.uid, profileImageUrl: String(describing: FIRAuth.auth()!.currentUser!.photoURL!))
        var otherUser:User!
        
        if currentUser.uid == chatsArray[indexPath.row].userId{
            otherUser = User(username: chatsArray[indexPath.row].otherUsername, userId: chatsArray[indexPath.row].otherUserId, profileImageUrl: chatsArray[indexPath.row].otherUserImageUrl)
        }else{
            otherUser = User(username: chatsArray[indexPath.row].username, userId: chatsArray[indexPath.row].userId, profileImageUrl: chatsArray[indexPath.row].userImageUrl)
        }
        
        chatFunctions.startChat(user1: currentUser, user2: otherUser)
        
        performSegue(withIdentifier: "goToChat", sender: self)
    }
    
    //MARK: Segue Method
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToChat"{
            
            if let chatVC = segue.destination as? ChatVC{
                
                chatVC.senderId = FIRAuth.auth()!.currentUser!.uid
                chatVC.senderDisplayName = FIRAuth.auth()!.currentUser!.displayName
                chatVC.chatRoomId = chatFunctions.chatRoom_Id
            }
            
        }
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
