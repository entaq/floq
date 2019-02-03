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
        
        Logger.log(result)
        if let accessToken = AccessToken.current {
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
            Auth.auth().signInAndRetrieveData(with: credential) { (data, err) in
                if (data != nil && err == nil){
                    let user = data?.user
                    
                    self.fluser = FLUser(uid:user!.uid , username:data?.additionalUserInfo?.username,profUrl: data?.user.photoURL, cliqs: 0)
                    self.saveUserdata(user: self.fluser!)
                }else{
                    let alert = UIAlertController.createDefaultAlert("OOPS!!", err!.localizedDescription,.alert, "Dismiss",.default, nil)
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
        print("The dispaly name is")
        let _ = Auth.auth().addStateDidChangeListener() { auth, user in
            let loginButton = LoginButton(readPermissions: [ .publicProfile, .email, .userFriends ])
            
            loginButton.delegate = self
            loginButton.center = self.view.center
            self.view.addSubview(loginButton)
            if user != nil  {
                self.saveUserdata(user: user!)
                let navVC = UINavigationController(rootViewController:HomeVC())
                self.present(navVC, animated: true, completion: nil)
            }
        }
        
        
        
    }
    
    func saveUserdata(user:User){
        DataService.main.getAndStoreProfileImg(imgUrl: user.photoURL!, uid: user.uid)
        if let _ = UserDefaults.standard.string(forKey: Fields.uid.rawValue) {
            return
        }
        let fuser = FLUser(uid: user.uid, username: user.displayName, profUrl: user.photoURL, cliqs: 0)
        DataService.main.setUser(user: fuser, handler: {_,_ in })
        UserDefaults.standard.set(user.uid, forKey: Fields.uid.rawValue)
        
    }
    
    func saveUserdata(user:FLUser){
        if let _ = UserDefaults.standard.string(forKey: Fields.uid.rawValue) {
            return
        }
        DataService.main.setUser(user: user, handler: {_,_ in })
        UserDefaults.set(user.uid, for:.uid)
        UserDefaults.set(user.username, for:.username)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
