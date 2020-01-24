//
//  PhotoCell.swift
//  Floq
//
//  Created by Mensah Shadrach on 16/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit
import FirebaseStorage
import SDWebImage

class PhotoCell: UICollectionViewCell, Identity {

    @IBOutlet weak var selectedCheck: UIImageView!
    @IBOutlet weak var alertIcon: UIView!
    @IBOutlet weak var imageView: UIImageView!
    let notifier = CommentNotificationEngine()
    private var uuid = UUID()
    var itemSelected:Bool = false
    private var photoID:String?
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeTo(subscription: .newHighlight, selector: #selector(canHighlight(_:)))
        subscribeTo(subscription: .clearSelection, selector: #selector(clears))
        subscribeTo(subscription: .cellShakeAnim, selector: #selector(performTheShake))
        self.layer.cornerRadius = 3
        alertIcon.backgroundColor = .orangeRed
        //alertIcon.clipsToBounds = true
        alertIcon.isHidden = true
        alertIcon.layer.cornerRadius = 5
        alertIcon.layer.shadowColor = UIColor.black.cgColor
        alertIcon.layer.shadowOpacity = 0.9
        alertIcon.layer.shadowRadius = 3
        alertIcon.layer.shadowOffset = CGSize(width: 0, height: 2)
        selectedCheck.isHidden = true

    }
    

    
    override func prepareForReuse() {
        super.prepareForReuse()
        alertIcon.isHidden = true
        imageView.image = nil
    }
    
    
    @objc func performTheShake(){
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DMakeRotation(.Angle(-3), 0, 0, 1.0))
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(.Angle(3), 0, 0, 1.0))
        animation.duration = 0.25
        animation.repeatCount = .infinity
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        layer.add(animation, forKey: Self.Identifier)
        
    }
    
    @objc func stopShakeAnim(){
        layer.removeAnimation(forKey: Self.Identifier)
    }
    
    
    func setSeleted(){
        itemSelected = !itemSelected
        selectedCheck.isHidden = !itemSelected
        
    }
    
    @objc func clears(){
        selectedCheck.isHidden = true
        itemSelected = false
        stopShakeAnim()
    }
    
    func configureCell(ref:StorageReference,photoID:String){
        self.photoID = photoID
        //imageView.sd_setImage(with: ref, placeholderImage:nil)
        notify(photoID)
        let size = self.bounds.size
        //DispatchQueue.global().async { [weak self] in
        ImageProcess.main.downloadImage(ref: ref, size: size, cellID: uuid) { (image) in
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = image
                //print("Image Thumb sixe: \(image.byteSize)")
            }
        }
        //imageView.loadImagewith(ref: ref)
//        DispatchQueue.global().async {
//            let process = ImageProcess(ref: ref, size: size)
//            process.delegate = self
//        }
        
    
    }
    
    
    func notify(_ id:String){
       
        
        if notifier.canHighlight(photo: id){
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


extension PhotoCell:ImageProcessDelegate{
    
    func imageReady(_ image: UIImage) {
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
}
