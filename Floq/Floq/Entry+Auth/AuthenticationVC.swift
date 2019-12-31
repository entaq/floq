//
//  AuthenticationVC.swift
//  Floq
//
//  Created by Shadrach Mensah on 31/12/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class AuthenticationVC: UIViewController {

    @IBOutlet weak var eulalable: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let attributedString = NSMutableAttributedString(string: "By signing into floq you agree to \nPrivacy Policy and our End User\nLicense Agreement", attributes: [
          .font: UIFont.systemFont(ofSize: 16.0, weight: .light),
          .foregroundColor: UIColor.white
        ])
        attributedString.addAttribute(.foregroundColor, value: UIColor.slate, range: NSRange(location: 35, length: 14))
        attributedString.addAttribute(.foregroundColor, value: UIColor.slate, range: NSRange(location: 58, length: 26))
        eulalable.attributedText = attributedString
        addlableGesture()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func googlePressed(_ sender: UIButton) {
        
    }
    
    @IBAction func faceBookPressed(_ sender: UIButton) {
        
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
