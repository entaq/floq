//
//  FirebaseAuth+Extensions.swift
//  Floq
//
//  Created by Mensah Shadrach on 01/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import FirebaseAuth
import FacebookCore
import FacebookLogin


extension Auth{
    
    class func logout(_ completion:CompletionHandlers.storage){
      
        do{
            try auth().signOut()
             UserDefaults.invalidateUserData()
            completion(true,nil)
        }catch let err{
            completion(false,err.localizedDescription)
        }
    }
    
    class func deActivateAccount(_ completion:@escaping CompletionHandlers.storage){
        let credemtial = FacebookAuthProvider.credential(withAccessToken: AccessToken.current?.authenticationToken ?? "")
        auth().signInAndRetrieveData(with: credemtial) { (data, err) in
            if let err = err{
                completion(false,err.localizedDescription)
            }else{
                auth().currentUser?.delete(completion: { (err) in
                    
                    if let err = err{
                        completion(false,err.localizedDescription)
                    }else{
                        UserDefaults.invalidateUserData()
                        completion(true,nil)
                    }
                })
            }
        }
        
    }
}
