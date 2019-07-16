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
        //let url = URL(string: "itms-apps://itunes.apple.com/us/app/id1003110219")!
        openAppStore(url:url)
    }
    
}

//"itms-apps://itunes.apple.com/app/id1024941703"
//https://itunes.apple.com/us/app/floq/id1003110219?ls=1&mt=8
//1003110219
//"itms-apps://itunes.apple.com/us/app/id1003110219"
