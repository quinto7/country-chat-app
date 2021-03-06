//
//  Message.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 6/10/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Message {
    
    var username: String!
    var text: String!
    var key: String = ""
    var mediaType:String!
    var mediaUrl:String!
    var ref: FIRDatabaseReference!
    var senderId: String!
    
    init(snapshot: FIRDataSnapshot){
        
        let values = snapshot.value as! Dictionary<String, Any>
        
        ref = snapshot.ref
        key = snapshot.key
        username = values["username"] as? String
        text = values["text"] as? String
        senderId = values["senderId"] as? String
        mediaType = values["mediaType"] as? String
        mediaUrl = values["mediaUrl"] as? String

        
    }
    
    init(text:String, key:String = "", username:String, senderId: String, mediaType:String, mediaUrl:String){
        
        self.text = text
        self.key = key
        self.username = username
        self.senderId = senderId
        self.mediaUrl = mediaUrl
        self.mediaType = mediaType
    }
    
    func toAny() -> [String : Any]{
        
        return ["text": text, "username":username, "senderId": senderId, "mediaType": mediaType, "mediaUrl": mediaUrl]
    }
}
