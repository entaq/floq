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
    func photoselected()
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
        let Tap = UITapGestureRecognizer(target: self, action: #selector(selectPhoto))
        Tap.numberOfTapsRequired = 1
        addGestureRecognizer(Tap)
        let dTap = UITapGestureRecognizer(target: self, action: #selector(likeAPhoto))
        dTap.numberOfTapsRequired = 2
        addGestureRecognizer(dTap)
        Tap.require(toFail: dTap)
        
    }
    
    
    func setImage(_ photo:PhotoItem){
        
        imageView.sd_setImage(with: storageRef.child(photo.fileID), placeholderImage: nil)
    }
    
    @objc func selectPhoto(){
        delegate?.photoselected()
    }
    
    @objc func likeAPhoto(){
        delegate?.photoWasLiked()
    }

}



