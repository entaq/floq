//
//  ViewController.swift
//  Floq
//
//  Created by Arun Nagarajan on 3/26/17.
//  Copyright © 2017 Arun Nagarajan. All rights reserved.
//

import UIKit
import Firebase

import Firebase
import FirebaseAuthUI
import FirebasePhoneAuthUI



class ViewController: UIViewController, FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        print(user?.displayName)
        print("hey logged in")
    }
    

    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBAction func loginPressed() {
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!)
            ]
        authUI?.providers = providers
        let phoneProvider = authUI?.providers.first as! FUIPhoneAuth
        phoneProvider.signIn(withPresenting: self, phoneNumber: nil)

//        let phoneAuth = FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!)

//        phoneAuth.signIn(withPresenting: self, phoneNumber: nil)
        
//        let authViewController = authUI!.authViewController()
//
//        present(authViewController, animated: true, completion: nil)
        
        
//        let phoneProvider = FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!)
//        phoneProvider.signIn(withPresenting: self, phoneNumber: nil)

//        if let phoneNumber = phoneNumber.text {
//            self.showSpinner {
//                // [START phone_auth]
//                PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
//                    // [START_EXCLUDE silent]
//                    self.hideSpinner {
//                        // [END_EXCLUDE]
//                        if let error = error {
//                            self.showMessagePrompt(error.localizedDescription)
//                            return
//                        }
//                        // Sign in using the verificationID and the code sent to the user
//                        // [START_EXCLUDE]
//                        guard let verificationID = verificationID else { return }
//                        self.showTextInputPrompt(withMessage: "Verification Code:") { (userPressedOK, verificationCode) in
//                            if let verificationCode = verificationCode {
//                                // [START get_phone_cred]
//                                let credential = PhoneAuthProvider.provider().credential(
//                                    withVerificationID: verificationID,
//                                    verificationCode: verificationCode)
//                                // [END get_phone_cred]
//                                self.firebaseLogin(credential)
//                            } else {
//                                self.showMessagePrompt("verification code can't be empty")
//                            }
//                        }
//                    }
//                    // [END_EXCLUDE]
//                }
//                // [END phone_auth]
//            }
//        } else {
//            self.showMessagePrompt("phone number can't be empty")
//        }
        
    }

    func firebaseLogin(_ credential: AuthCredential) {
        showSpinner {
            if let user = Auth.auth().currentUser {
                // [START link_credential]
                user.link(with: credential) { (user, error) in
                    // [START_EXCLUDE]
                    self.hideSpinner {
                        if let error = error {
                            self.showMessagePrompt(error.localizedDescription)
                            return
                        }
//                        self.tableView.reloadData()
                    }
                    // [END_EXCLUDE]
                }
                // [END link_credential]
            } else {
                // [START signin_credential]
                Auth.auth().signIn(with: credential) { (user, error) in
                    // [START_EXCLUDE silent]
                    self.hideSpinner {
                        // [END_EXCLUDE]
                        if let error = error {
                            // [START_EXCLUDE]
                            self.showMessagePrompt(error.localizedDescription)
                            // [END_EXCLUDE]
                            return
                        }
                        // User is signed in
                        // [START_EXCLUDE]
                        // Merge prevUser and currentUser accounts and data
                        // ...
                        // [END_EXCLUDE]
                    }
                }
                // [END signin_credential]
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

