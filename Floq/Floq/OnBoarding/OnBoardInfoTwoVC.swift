//
//  OnBoardInfoTwoVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 05/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class OnBoardInfoTwoVC: UIViewController {

    @IBOutlet weak var googleSignIn: UIButton!
    @IBOutlet weak var loginButt: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func googleSignInPressed(_ sender: UIButton) {
        if let eulavc = storyboard?.instantiateViewController(withIdentifier: "\(EULAVC.self)") as? UINavigationController{
            if let eu = eulavc.viewControllers.first as? EULAVC{
                eu.signInMethod = .google
                present(eulavc, animated: true, completion: nil)
            }
            
        }
    }
    @IBAction func didPressLogin(_ sender: Any) {
        if let eulavc = storyboard?.instantiateViewController(withIdentifier: "\(EULAVC.self)") as? UINavigationController{
            //eulavc.method = .facebook
            if let eu = eulavc.viewControllers.first as? EULAVC{
                eu.signInMethod = .facebook
                present(eulavc, animated: true, completion: nil)
            }
            
            
        }
    }
    
    
    
    
//        let fuser = FLUser(uid: user.uid, username: user.displayName, profUrl: user.photoURL, cliqs: 0)
//        DataService.main.setUser(user: fuser, handler: {_,_ in })
//        UserDefaults.set(fuser.uid, for:.uid)
//        UserDefaults.set(fuser.username, for:.username)
//        InstanceID.instanceID().instanceID(handler: { (result, err) in
//            if let result = result{
//                DataService.main.saveNewUserInstanceToken(token: result.token, complete: { (success, err) in
//                    if success{
//                        UserDefaults.set(result.token, for: .instanceToken)
//                    }else{
//
//                        Logger.log(err)
//                    }
//                })
//            }
//        })
    
    
    

}
