//
//  FinalOnBoardVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 05/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import FirebaseAuth.FIRUser

class FinalOnBoardVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var nickNameText: UITextField!
    
    var user:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nickNameText.layer.borderColor = UIColor.black.cgColor
        nickNameText.layer.borderWidth = 1
        nickNameText.layer.cornerRadius = 4
        
    }
    
    func saveUserdata(user:User){
        DataService.main.getAndStoreProfileImg(imgUrl: user.photoURL!, uid: user.uid)
        if let _ = UserDefaults.standard.string(forKey: Fields.uid.rawValue) {
            return
        }
        let fuser = FLUser(uid: user.uid, username: nickNameText.text!, profUrl: user.photoURL, floqs: nil)
        DataService.main.setUser(user: fuser, handler: {_,_ in })
        UserDefaults.set(fuser.uid, for:.uid)
        UserDefaults.set(fuser.username, for:.username)
        let navC = UINavigationController(rootViewController: HomeVC(nil))
        self.present(navC, animated: true, completion: nil)
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.text!.count > 4) {
            saveUserdata(user: user)
        }else{
            let alert = UIAlertController.createDefaultAlert("OOPS!!", "Please provide an a nickname of more than four letters",.alert, "Dismiss",.default, nil)
            self.present(alert, animated: true, completion: nil)
        }
        return true
    }

}

