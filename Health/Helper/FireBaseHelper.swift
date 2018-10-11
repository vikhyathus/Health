//
//  FireBaseHelper.swift
//  Health
//
//  Created by Vikhyath on 27/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import Firebase

class FireBaseHelper {
    
    static func getUserID() -> (Bool, String) {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            return (false, "Error fetching user Id")
        }
        
        return (true, userID)
    }
}
