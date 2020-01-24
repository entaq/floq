//
//  AuthenticationVC.swift
//  Floq
//
//  Created by Shadrach Mensah on 31/12/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit
import GoogleSignIn
import FacebookCore
import FacebookLogin
import FirebaseAuth

class AuthenticationVC: UIViewController {

    @IBOutlet weak var eulalable: UILabel!
    
    var pager:UIPageControl?
    private lazy var loader:GradientView = {
        let view = GradientView(frame: .zero)
        view.isHidden = true
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pager?.currentPage = 4
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    
    func setup(){
        let attributedString = NSMutableAttributedString(string: "By signing into floq you agree to \nPrivacy Policy and our End User\nLicense Agreement", attributes: [
          .font: UIFont.systemFont(ofSize: 16.0, weight: .light),
          .foregroundColor: UIColor.white
        ])
        attributedString.addAttribute(.foregroundColor, value: UIColor.slate, range: NSRange(location: 35, length: 14))
        attributedString.addAttribute(.foregroundColor, value: UIColor.slate, range: NSRange(location: 58, length: 26))
        eulalable.attributedText = attributedString
        addlableGesture()
        view.addSubview(loader)
        loader.layout{
            $0.bottom == view.bottomAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.height |=| 10
        }
    }
    
    @IBAction func googlePressed(_ sender: UIButton) {
        loader.isHidden = false
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func faceBookPressed(_ sender: UIButton) {
        facebooklogin()
    }
    
    func addlableGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(showEula(_:)))
        tap.numberOfTapsRequired = 1
        eulalable.isUserInteractionEnabled = true
        eulalable.addGestureRecognizer(tap)
    }
    
    @objc func showEula(_ sender:UITapGestureRecognizer){
        if let nav = storyboard?.instantiateViewController(withIdentifier: "EULAVC1") as? UINavigationController{
            nav.modalPresentationStyle = .pageSheet
            present(nav, animated: true, completion: nil)
        }
    }
    
    func facebooklogin(){
        loader.isHidden = false
        let flogin = LoginManager()
        flogin.logOut()
        
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
        
        Auth.auth().signIn(with: credential) { (data, err) in
            if (data != nil && err == nil){
                if let user = data?.user{
                    
                    DataService.main.isRegistered(uid: user.uid, handler: { [weak self] (exists, username) in
                        if exists{
                            self?.saveUserdata(user: user)
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
                            self?.present(vc, animated: true, completion: nil)
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
        var url:URL?
        if App.signInMethod == .facebook{
            url  = URL(string: "https://graph.facebook.com/\(userID)/picture?width=400&height=400")
        }else{
            //url    URL    "https://lh3.googleusercontent.com/a-/AAuE7mDiAkODg80e2iUUY05fnyWJFrWjBSON3x-X082qEQ=s96-c"
            url = user.photoURL
            if let sized = url?.absoluteString{
                let newurlstring = sized.replacingOccurrences(of: "s96-c", with: "s400-c")
                url = URL(string: newurlstring)
                
            }
        }
        DataService.main.getAndStoreProfileImg(imgUrl: url!, uid: user.uid)
        if let _ = UserDefaults.standard.string(forKey: Fields.uid.rawValue) {
            return
        }
    }
    
}


extension AuthenticationVC:GIDSignInDelegate{
    
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



extension AuthenticationVC:GIDSignInUIDelegate{}
