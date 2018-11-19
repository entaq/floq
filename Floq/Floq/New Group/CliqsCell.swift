//
//  CliqsCell.swift
//  Floq
//
//  Created by Mensah Shadrach on 12/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit
import FirebaseStorage



class CliqsCell: UICollectionViewCell {

    @IBOutlet weak var avi: UIImageView!
    @IBOutlet weak var containerView: ContainerView!
    @IBOutlet weak var joinbutt: FButton!
    @IBOutlet weak var creator: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var imagevOverlay: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageview.clipsToBounds = true
        avi.clipsToBounds = true
        avi.layer.cornerRadius = avi.frame.width / 2
        avi.layer.borderWidth = 2.0
        avi.layer.borderColor = UIColor.white.cgColor
        imageview.contentMode = .scaleAspectFill
        imageview.layer.cornerRadius = 5.0
        imagevOverlay.layer.cornerRadius = 5.0
    }
    
    
    func configureView(reference: StorageReference,title:String, creator:String) {
        imageview.sd_setImage(with: reference, placeholderImage: nil)
        containerView.sendSubview(toBack: imageview)
        self.title.text = title
        self.creator.text = creator
    }
    

    @IBAction func jointapped(_ sender: Any) {
        
    }
}


