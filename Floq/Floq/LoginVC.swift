//
//  ViewController.swift
//  Floq
//
//  Created by Arun Nagarajan on 3/26/17.
//  Copyright © 2017 Arun Nagarajan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FacebookLogin
import FacebookCore

class LoginVC: UIViewController, LoginButtonDelegate {
    
    var fluser:FLUser?
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        
        
        if let accessToken = AccessToken.current {
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
            Auth.auth().signInAndRetrieveData(with: credential) { (data, err) in
                if (data != nil && err == nil){
                    let user = data?.user
                    self.fluser = FLUser(uid:user!.uid , username:data?.additionalUserInfo?.username, floqs: nil)
                }else{
                    let alert = createDefaultAlert("OOPS!!", err!.localizedDescription,.alert, "Dismiss",.default, nil)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        //
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = Auth.auth().addStateDidChangeListener() { auth, user in
            let loginButton = LoginButton(readPermissions: [ .publicProfile, .email, .userFriends ])
            
            loginButton.delegate = self
            loginButton.center = self.view.center
            self.view.addSubview(loginButton)
            if user != nil  {
                
                let navVC = UINavigationController(rootViewController:CliqsVC(self.fluser))
                
                
                self.present(navVC, animated: true, completion: nil)
            }
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
