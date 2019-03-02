//
//  ForceUpdateVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 29/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class ForceUpdateVC: UIViewController {

    
    @IBOutlet weak var infoText: UILabel!
    @IBOutlet weak var updateabutton: UIButton!
    var info:String?
    var url:URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let info = info{
            infoText.text = info
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func updatePressed(_ sender: Any) {
        openAppStore(url:url)
    }
    
}
