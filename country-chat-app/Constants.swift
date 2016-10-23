//
//  Constants.swift
//  country-chat-app
//
//  Created by Quinto Cossio on 19/9/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

var databaseRef: FIRDatabaseReference! {
    
    return FIRDatabase.database().reference()
}

var storageRef: FIRStorageReference! {
    
    return FIRStorage.storage().reference()
}

