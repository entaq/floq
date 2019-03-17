//
//  UserSettingsTVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 01/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import FirebaseAuth
import SafariServices

class UserSettingsTVC: UITableViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            openSettings()
            break
        case 1:
            lauchWebView()
            break
        case 2:
             logout()
            break
        case 3:
            deactivateAccount()
            break
        default:
           break
        }
    }
    
    
    
    func deactivateAccount(){
        let alert = UIAlertController.createDefaultAlert("Log Out", "You are about to deactivate your account.",.actionSheet, "Cancel",.default, nil)
        let action = UIAlertAction(title: "Deactivate", style: .destructive) { (ac) in
            DataService.main.cleanUp(uid: UserDefaults.uid)
            Auth.deActivateAccount { (success, err) in
                if success{
                    
                    self.navigationController?.dismiss(animated: true, completion: nil)
                    
                }else{
                    self.present(UIAlertController.createDefaultAlert("🚨🚨 Error 🚨🚨", err ?? "Unknown Error",.alert, "OK",.default, nil), animated: true, completion: nil)
                }
            }
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func logout(){
        let alert = UIAlertController.createDefaultAlert("Log Out", "You are about to logout from your account",.alert, "Cancel",.default, nil)
        let action = UIAlertAction(title: "Logout", style: .destructive) { (ac) in

            Auth.logout { (success, err) in
                
                if success{
                    let onboard = UIStoryboard.main.instantiateViewController(withIdentifier: HomeOnBaordVC.identifier) as! HomeOnBaordVC
                    self.present(onboard, animated: true, completion: nil)
                    
                }else{
                    self.present(UIAlertController.createDefaultAlert("🚨🚨 Error 🚨🚨", err ?? "Unknown Error",.alert, "OK",.default, nil), animated: true, completion: nil)
                }
            }
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func openSettings(){
        if let seturl = URL(string: UIApplication.openSettingsURLString){
            if UIApplication.shared.canOpenURL(seturl){
                UIApplication.shared.open(seturl, options: [:]) { (success) in
                    print("Sucess")
                }
            }
        }
        
    }
    
    
    func lauchWebView(){
        
        guard let url = URL(string: "https://jberkey78.github.io/floq-beta") else{return}
        let controller:SFSafariViewController
        if #available(iOS 11.0, *) {
            let config = SFSafariViewController.Configuration()
            config.barCollapsingEnabled = true
            config.entersReaderIfAvailable = true
            controller = SFSafariViewController(url: url, configuration: config)
        } else {
            // Fallback on earlier versions
            controller = SFSafariViewController(url: url)
        }
        
        controller.preferredControlTintColor = .white
        controller.preferredBarTintColor = .seafoamBlue
        present(controller, animated: true, completion: nil)

    }
    
    /*
     Mock Function to produce dummy text
     */
    
    func dummyAlert(title:String){
        let alert = UIAlertController.createDefaultAlert(title, "This is a dummy alert, \(title) links will be added before launch",.alert, "OK",.default, nil)
        present(alert, animated: true, completion: nil)
        
    }
    
    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
