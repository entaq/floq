//
//  FullScreenCell.swift
//  Floq
//
//  Created by Mensah Shadrach on 17/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import FirebaseStorage

class FullScreenCell: UICollectionViewCell {
    
    private var storageRef:StorageReference{
        return Storage.storage().reference()
    }
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func setImage(_ photo:PhotoItem){
        if let image = DataService.main.getCachedImage(for: photo.photoID){
            imageView.image = image
        }else{
            //imageView.image = UIImage(named: "featherLarge")
            imageView.sd_setImage(with: storageRef.child(photo.photoID))
//            imageView.sd_setImage(with: storageRef.child(photo.photoID), placeholderImage:nil) { (img, err, cacheType, ref) in
//                if img != nil{
//                    DataService.main.cache(img!, key: photo.photoID)
//                }
//            }
            
        }
    }

}
