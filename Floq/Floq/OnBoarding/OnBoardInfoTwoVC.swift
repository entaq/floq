//
//  OnBoardInfoTwoVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 05/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import FirebaseAuth
import FacebookCore
import FacebookLogin
import FirebaseInstanceID

class OnBoardInfoTwoVC: UIViewController {

    @IBOutlet weak var loginButt: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func didPressLogin(_ sender: Any) {
        facebooklogin()
    }
    
    
    
    func facebooklogin(){
        let flogin = LoginManager()
        flogin.logIn(readPermissions: [.publicProfile, .email], viewController: self) { (result) in
            switch (result){
            case .cancelled:
                Logger.log("User Cancelled")
                break
            case .failed(let err):
                Logger.log(err)
                break
            case .success(grantedPermissions: _, declinedPermissions:  _, token: let token):
                self.facebookLogCompletion(token: token)
                break
            }
        }
    }
    

    func facebookLogCompletion(token:AccessToken){
        let credential = FacebookAuthProvider.credential(withAccessToken: token.authenticationToken)
        Auth.auth().signInAndRetrieveData(with: credential) { (data, err) in
            if (data != nil && err == nil){
                if let user = data?.user{
                    DataService.main.isRegistered(uid: user.uid, handler: { (exists, username) in
                        if exists{
                            self.saveUserdata(user: user)
                            UserDefaults.set(username!, for: .username)
                            UserDefaults.set(user.uid, for: .uid)
                            if let appdel = UIApplication.shared.delegate as? AppDelegate{
                                appdel.mainEngine = CliqEngine()
                                let navC = UINavigationController(rootViewController: HomeVC())
                                DispatchQueue.main.async {
                                    appdel.window?.rootViewController = navC
                                    appdel.window?.makeKeyAndVisible()
                                    appdel.selfSync()
                                }
                            }
                            
                        }else{
                            let vc = UIStoryboard.main.instantiateViewController(withIdentifier: FinalOnBoardVC.identifier) as! FinalOnBoardVC
                            vc.user = user
                            self.present(vc, animated: true, completion: nil)
                        }
                    })
                    
                }
            }else{
                let alert = UIAlertController.createDefaultAlert("OOPS!!", err!.localizedDescription,.alert, "Dismiss",.default, nil)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    

    func saveUserdata(user:User){
        let userID = AccessToken.current?.userId ?? ""
        let url = URL(string: "https://graph.facebook.com/\(userID)/picture?width=400&height=400")
        DataService.main.getAndStoreProfileImg(imgUrl: url!, uid: user.uid)
        if let _ = UserDefaults.standard.string(forKey: Fields.uid.rawValue) {
            return
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
