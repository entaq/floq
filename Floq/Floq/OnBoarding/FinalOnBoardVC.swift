//
//  FinalOnBoardVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 05/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import FirebaseAuth.FIRUser
import FacebookLogin
import FacebookCore

class FinalOnBoardVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var nickNameText: UITextField!
    
    var user:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nickNameText.layer.borderColor = UIColor.black.cgColor
        nickNameText.layer.borderWidth = 1
        nickNameText.layer.cornerRadius = 4
        nickNameText.delegate = self
        
    }
    
    func saveUserdata(user:User){
       
        DataService.main.getAndStoreProfileImg(imgUrl: user.photoURL!, uid: user.uid)
        if let _ = UserDefaults.standard.string(forKey: Fields.uid.rawValue) {
            return
        }
        let fuser = FLUser(uid: user.uid, username: nickNameText.text!, profUrl: user.photoURL, cliqs: 0)
        DataService.main.setUser(user: fuser, handler: {_,_ in })
        UserDefaults.set(fuser.uid, for:.uid)
        UserDefaults.set(fuser.username, for:.username)
        let navC = UINavigationController(rootViewController: HomeVC())
        if let appdel = UIApplication.shared.delegate as? AppDelegate{
            appdel.mainEngine = CliqEngine()
            appdel.window?.rootViewController = UINavigationController(rootViewController: HomeVC())
            appdel.window?.makeKeyAndVisible()
            appdel.selfSync()
        }
        
        self.present(navC, animated: true, completion: nil)
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        if (textField.text!.count > 0) {
            saveUserdata(user: user)
        }else{
            let alert = UIAlertController.createDefaultAlert("OOPS!!", "Please provide an a nickname",.alert, "Dismiss",.default, nil)
            self.present(alert, animated: true, completion: nil)
        }
        return true
    }

}

