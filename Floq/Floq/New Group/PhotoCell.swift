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
    let notifier = PhotoNotification()
    private var photoID:String?
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeTo(subscription: .cmt_photo_notify, selector: #selector(canHighlight(_:)))
        self.layer.cornerRadius = 3
        alertIcon.backgroundColor = .orangeRed
        //alertIcon.clipsToBounds = true
        alertIcon.isHidden = true
        alertIcon.layer.cornerRadius = 5
        alertIcon.layer.shadowColor = UIColor.black.cgColor
        alertIcon.layer.shadowOpacity = 0.9
        alertIcon.layer.shadowRadius = 3
        alertIcon.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        // Initialization code
    }
    
    override var isSelected: Bool{
        didSet{
            guard let id = photoID else {return}
            if !alertIcon.isHidden{
                notifier.endNotifying(id)
                alertIcon.isHidden = true
            }
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
        notify(photoID)
    }
    
    
    func notify(_ id:String){
        let notify = notifier.fetchExistingNotication(id)
        if notify?.notify ?? false{
            alertIcon.isHidden = false
        }else{
            alertIcon.isHidden = true
        }
    }
    
    @objc func canHighlight(_ notification:Notification){
        guard let id = notification.userInfo?[.info] as? String, let pid = photoID else {return}
        if id == pid{
            notify(id)
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
