//
//  ChatRoom.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 7/10/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct ChatRoom {
    
    var username: String!
    var otherUsername: String!
    var userId: String!
    var otherUserId: String!
    var members: [String]!
    var chatRoomId: String!
    var key: String = ""
    var lastMessage: String!
    var ref: FIRDatabaseReference!
    var userImageUrl: String!
    var otherUserImageUrl:String!
    
    init(snapshot: FIRDataSnapshot){
        
        let values = snapshot.value as! Dictionary<String, Any>
        
        ref = snapshot.ref
        key = snapshot.key
        username = values["username"] as? String
        otherUsername = values["otherUsername"] as? String
        userId = values["userId"] as? String
        otherUserId = values["otherUserId"] as? String
        members = values["members"] as? [String]
        chatRoomId = values["chatRoomId"] as? String
        lastMessage = values["lastMessage"] as? String
        userImageUrl = values["userImageUrl"] as? String
        otherUserImageUrl = values["otherUserImageUrl"] as? String
        
    }
    
    init(username: String, otherUsername: String, userId: String, otherUserId: String, members: [String], chatRoomId: String, key: String = "", lastMessage: String, userImageUrl: String, otherUserImageUrl:String){
        
        self.username = username
        self.otherUsername = otherUsername
        self.userId = userId
        self.otherUserId = otherUserId
        self.members = members
        self.chatRoomId = chatRoomId
        self.lastMessage = lastMessage
        self.userImageUrl = userImageUrl
        self.otherUserImageUrl = otherUserImageUrl
        
    }
    
    func toAny() -> [String: AnyObject]{
        
        return ["username": username as AnyObject, "otherUsername": otherUsername as AnyObject, "userId": userId as AnyObject, "otherUserId": otherUserId as AnyObject, "members": members as AnyObject, "chatRoomId": chatRoomId as AnyObject, "lastMessage": lastMessage as AnyObject, "userImageUrl": userImageUrl as AnyObject, "otherUserImageUrl":otherUserImageUrl as AnyObject]
    }
}
