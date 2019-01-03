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
        return Storage.floqPhotos
    }
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.clipsToBounds = true
        // Initialization code
    }
    
    
    func setImage(_ photo:PhotoItem){
        imageView.sd_setImage(with: storageRef.child(photo.photoID))
        
    }

}
