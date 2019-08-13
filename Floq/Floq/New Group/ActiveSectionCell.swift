//
//  ActiveSectionCell.swift
//  Floq
//
//  Created by Mensah Shadrach on 04/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class ActiveSectionCell: UICollectionViewCell {

    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var baseView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        baseView.layer.cornerRadius = 20
        // Initialization code
    }
    
    
    func configure(title:String){
        titlelabel.text = "View \(title)"
    }

}
