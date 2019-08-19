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
    var subscription = CMTSubscription()
    private var photoID:String?
    override func awakeFromNib() {
        super.awakeFromNib()
        //subscribeTo(subscription: .newHighlight, selector: #selector(canHighlight(_:)))
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
    
    override var isSelected: Bool{
        didSet{
            guard let id = photoID else {return}
            //subscription.endHightlightFor(id)
            //alertIcon.isHidden = true
        }
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
        let photo = subscription.fetchPhotoSub(id: id)
        if photo?.canBroadcast ?? false{
            alertIcon.isHidden = false
        }else{
            alertIcon.isHidden = true
        }
//        if (UIApplication.shared.delegate as? AppDelegate)?.mainEngine.canHiglight(photo: id) ?? false{
//            alertIcon.isHidden = false
//        }else{
//            alertIcon.isHidden = true
//        }
    }
    
    deinit {
        unsubscribe()
    }

}
