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
    
    @IBOutlet weak var scrollVIiew: UIScrollView!
    private var storageRef:StorageReference{
        return Storage.floqPhotos
    }
    weak var delegate:PhotoLikedDelegate?
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollVIiew.delegate = self
        scrollVIiew.showsVerticalScrollIndicator = false
        scrollVIiew.showsHorizontalScrollIndicator = false
        scrollVIiew.minimumZoomScale = 1
        scrollVIiew.maximumZoomScale = 4
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
        //DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: DispatchWorkItem(block: {
            //print("Full Image Thumb sixe: \(self.imageView.image?.byteSize ?? 0)")
        //}))
    }
    
    @objc func selectPhoto(){
        delegate?.photoselected()
    }
    
    @objc func likeAPhoto(){
        delegate?.photoWasLiked()
    }

}


extension FullScreenCell:UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
