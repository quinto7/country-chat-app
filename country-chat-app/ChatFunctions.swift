//
//  ChatFunctions.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 7/10/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct ChatFunctions {
    
    var chatRoom_Id = String()
    
    private var databaseRef:FIRDatabaseReference{
        
        return FIRDatabase.database().reference()
    }
    
    mutating func startChat(user1:User, user2:User){
        
        let userId1 = user1.uid!
        let userId2 = user2.uid!
        
        var chatRoomId = ""
        
        let comparison = userId1.compare(userId2).rawValue
        
        let members = [user1.username, user2.username]
        
        //Logic para evitar q se creen dos chatsId con la misma persona
        if comparison < 0{
            chatRoomId = userId1.appending(userId2) //Crea uid unicos entre estos dos
        }else{
            chatRoomId = userId2.appending(userId1)
        }
        
        //Logica para poder mantener el chat con alguien y quede guardado
        self.chatRoom_Id = chatRoomId
        self.createChatRoomId(user1: user1, user2: user2, members: members as! [String], chatRoomId: chatRoomId)
    }
    
    //Esta func primero chequea si existe un chatroom entre dos usuarios. Si no existe se ejecuta createNewChatRoom y se crea un chatroom nuevo
    private func createChatRoomId(user1: User, user2: User, members: [String], chatRoomId: String){
        
        //Hago una query a la database y chequeo si existe el chatRoomId
        let chatRoomRef = databaseRef.child("chatrooms").queryOrdered(byChild: "chatRoomId").queryEqual(toValue: chatRoomId)
        
        chatRoomRef.observe(.value, with: { (snapshot) in
            
            var createChatRoom = true
            
            if snapshot.exists() {
                
                if let values = snapshot.value as? [String: AnyObject]{
                    for chatRoom in values{
                        if chatRoom.value["chatRoomId"] as? String == chatRoomId{
                            createChatRoom = false
                        }
                    }
                }
                
            }
            //Si no existe, se va a crear una
            if createChatRoom{
                self.createNewChatRoomId(username: user1.username, otherUsername: user2.username, userId: user1.uid, otherUserId: user2.uid, members: members, chatRoomId: chatRoomId, lastMessage: "", userImageUrl: user1.profileImageUrl!, otherUserImageUrl: user2.profileImageUrl!)
            }
            
            
            }) { (error) in
                
                print(error.localizedDescription)
        }
        
        
    }
    
    private func createNewChatRoomId(username: String, otherUsername: String, userId: String, otherUserId: String, members: [String], chatRoomId: String, lastMessage: String, userImageUrl: String, otherUserImageUrl:String){
        
        let newChatRoom = ChatRoom(username: username, otherUsername: otherUsername, userId: userId, otherUserId: otherUserId, members: members, chatRoomId: chatRoomId, lastMessage: lastMessage, userImageUrl: userImageUrl, otherUserImageUrl: otherUserImageUrl)
        
        let chatRoomRef = databaseRef.child("chatrooms").child(chatRoomId)
        chatRoomRef.setValue(newChatRoom.toAny())
        
    }
    
    
    
    
}
