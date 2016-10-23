//
//  User.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 19/9/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct User{
    
    var username:String!
    var email:String!
    var profileImageUrl:String!
    var country:String!
    var key:String!
    var ref:FIRDatabaseReference?
    var uid:String!
    
    
    init(snapshot: FIRDataSnapshot){
        
        let values = snapshot.value as! Dictionary<String, AnyObject>
        
        key = snapshot.key
        ref = snapshot.ref
        username = values["username"] as? String
        email = values["email"] as? String
        profileImageUrl = values["profileImageUrl"] as? String
        country = values["country"] as? String
        uid = values["uid"] as? String
        
        
    }
    
    init(username:String, userId:String, profileImageUrl:String){
        
        self.username = username
        self.uid = userId
        self.profileImageUrl = profileImageUrl
    }
    
    
    
    
    
    
    
}
