//
//  FullScreenCell.swift
//  Floq
//
//  Created by Mensah Shadrach on 17/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import FirebaseStorage


protocol PhotoLikedDelegate:class {
    func photoWasLiked()
}

class FullScreenCell: UICollectionViewCell {
    
    private var storageRef:StorageReference{
        return Storage.floqPhotos
    }
    weak var delegate:PhotoLikedDelegate?
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.clipsToBounds = true
        let dTap = UITapGestureRecognizer(target: self, action: #selector(likeAPhoto))
        dTap.numberOfTapsRequired = 2
        addGestureRecognizer(dTap)
        
    }
    
    
    func setImage(_ photo:PhotoItem){
        imageView.sd_setImage(with: storageRef.child(photo.photoID))
        
    }
    
    @objc func likeAPhoto(){
        delegate?.photoWasLiked()
    }

}



