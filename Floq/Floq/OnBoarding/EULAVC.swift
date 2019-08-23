//
//  EULAVC.swift
//  Floq
//
//  Created by Shadrach Mensah on 04/05/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FacebookCore
import FacebookLogin
import FirebaseInstanceID
import GoogleSignIn

class EULAVC: UIViewController {
    
    enum SignInMethod{
        case facebook, google
    }
    @IBOutlet weak var optionsView:UIView!
    @IBOutlet weak var backButt: UIButton!
    
    @IBOutlet weak var loader: UIView!
    @IBOutlet weak var declineButt: UIButton!
    @IBOutlet weak var acceptButt: UIButton!
    
    var signInMethod:SignInMethod!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        App.setDomain(.Eula)
        loader.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if hidesOptions{
            declineButt.isHidden = true
            acceptButt.isHidden = true
            backButt.isHidden =  false
        }else{
            backButt.isHidden = true
        }
    }
    
    var hidesOptions = false

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func declineEULA(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goback(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func acceptEULA(_ sender: UIButton){
        let sheet = UIAlertController(title: "Sign In Options", message: "Please choose a sign in method", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Sign In with Google", style: .default, handler: { _ in
            GIDSignIn.sharedInstance()?.delegate = self
            
            GIDSignIn.sharedInstance()?.signIn()
        }))
        
        sheet.addAction(UIAlertAction(title: "Facebook", style: .default, handler: { _ in
            self.facebooklogin()
        }))
    }
    
    
    func facebooklogin(){
        let flogin = LoginManager()
        flogin.logOut()
        self.loader.isHidden = false
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
        signInWith(credential)
        
    }
    
    func signInWith(_ credential:AuthCredential){
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
                                    self.loader.removeFromSuperview()
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

}



extension EULAVC:GIDSignInDelegate{
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error{
            print("Google SigIn Error: \(error.localizedDescription)")
            return
        }
        
        guard let auth = user.authentication else {return}
        let cred = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        
        signInWith(cred)
    }
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        let alert = UIAlertController.createDefaultAlert("Authentication Error", "Unable to sign in with Google Account",.alert, "OK",.default, nil)
        present(alert, animated: true, completion: nil)
    }
}
