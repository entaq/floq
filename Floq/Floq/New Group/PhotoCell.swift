//
//  PhotoCell.swift
//  Floq
//
//  Created by Mensah Shadrach on 16/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit
import FirebaseStorage

class PhotoCell: UICollectionViewCell {

    @IBOutlet weak var alertIcon: UIView!
    @IBOutlet weak var imageView: UIImageView!
    private var photoID:String?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 3
        alertIcon.clipsToBounds = true
        alertIcon.isHidden = true
        alertIcon.layer.cornerRadius = 2.5
        alertIcon.layer.shadowColor = UIColor.darkGray.cgColor
        alertIcon.layer.shadowOpacity = 0.6
        alertIcon.layer.shadowRadius = 2
        alertIcon.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        alertIcon.isHidden = true
    }
    
    func configureCell(ref:StorageReference,photoID:String){
        self.photoID = photoID
        imageView.sd_setImage(with: ref, placeholderImage:nil)
        
    }
    
    
    @objc func canHighlight(_ notification:Notification){
        guard let id = photoID else {return}
        if (UIApplication.shared.delegate as? AppDelegate)?.mainEngine.canHiglight(photo: id) ?? false{
            alertIcon.isHidden = false
        }else{
            alertIcon.isHidden = true
        }
    }

}
