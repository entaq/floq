
//
//  UserListCell.swift
//  Floq
//
//  Created by Mensah Shadrach on 02/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class UserListCell: UITableViewCell {

    @IBOutlet weak var blockLable: UILabel!
    @IBOutlet weak var countlabel: UILabel!
    @IBOutlet weak var namelable:UILabel!
    @IBOutlet weak var imgview:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        blockLable.isHidden = true
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        blockLable.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(id:String,name:String, count:Int){
        namelable.text = name
        imgview.setAvatar(uid: id)
        countlabel.text = "\(count)"
        blockLable.isHidden = (appUser != nil) ? !appUser!.hasBlocked(user: id) : true
    }

}
