//
//  OnBoardInfoTwoVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 05/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class OnBoardInfoTwoVC: UIViewController {

    @IBOutlet weak var heightAnchor: NSLayoutConstraint!
    @IBOutlet weak var googleSignIn: UIButton!
    @IBOutlet weak var loginButt: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        // Do any additional setup after loading the view.
    }
    
    
    func config(){
        let handle = UIScreen.main.screenType()
        
        switch handle {
        case .xmax_xr:
            heightAnchor.constant = 400
            return
        case .xs_x:
            heightAnchor.constant = 400
            return
        case .pluses:
            heightAnchor.constant = 320
            return
        case .eight_lower:
            heightAnchor.constant = 320
        default:
            heightAnchor.constant = 250
            return
        }
    }
    
    

    @IBAction func googleSignInPressed(_ sender: UIButton) {
        if let eulavc = storyboard?.instantiateViewController(withIdentifier: "EULAVC1") as? UINavigationController{
            if let eu = eulavc.viewControllers.first as? EULAVC{
                eu.signInMethod = .google
                eulavc.modalPresentationStyle = .fullScreen
                present(eulavc, animated: true, completion: nil)
            }
            
        }
    }
    @IBAction func didPressLogin(_ sender: Any) {
        if let eulavc = storyboard?.instantiateViewController(withIdentifier: "EULAVC1") as? UINavigationController{
            //eulavc.method = .facebook
            if let eu = eulavc.viewControllers.first as? EULAVC{
                eulavc.modalPresentationStyle = .fullScreen
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
