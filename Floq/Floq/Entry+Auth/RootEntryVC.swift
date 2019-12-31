//
//  RootEntryVC.swift
//  Floq
//
//  Created by Shadrach Mensah on 30/12/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class RootEntryVC: UIViewController {

    @IBOutlet weak var headerLable: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func beginOnboarding(_ sender: UIButton) {
        if let onboard = storyboard?.instantiateViewController(withIdentifier: HomeOnBaordVC.identifier) as? HomeOnBaordVC{
            onboard.modalPresentationStyle = .fullScreen
            present(onboard, animated: true, completion: nil)
        }
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        if let authVc = storyboard?.instantiateViewController(withIdentifier:AuthenticationVC.identifier) as? AuthenticationVC{
            authVc.modalPresentationStyle = .fullScreen
            self.present(authVc, animated: true, completion: nil)
        }
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
