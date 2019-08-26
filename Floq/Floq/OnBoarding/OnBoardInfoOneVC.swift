//
//  OnBoardInfoOneVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 05/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class OnBoardInfoOneVC: UIViewController {

    @IBOutlet weak var secondlale: UILabel!
    @IBOutlet weak var toplable: UILabel!
    @IBOutlet weak var heightAnchor: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        configDevice()
        // Do any additional setup after loading the view.
    }
    
    func configDevice(){
        let handle = UIScreen.main.screenType()
        
        switch handle {
        case .xmax_xr:
            heightAnchor.constant = 450
            return
        case .xs_x:
            heightAnchor.constant = 400
            return
        case .pluses:
            heightAnchor.constant = 380
            return
        case .eight_lower:
            heightAnchor.constant = 300
        default:
            heightAnchor.constant = 220
            toplable.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            secondlale.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            return
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
