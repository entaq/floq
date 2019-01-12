//
//  FullScreenPhotoSection.swift
//  Floq
//
//  Created by Mensah Shadrach on 17/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit
import IGListKit
import FirebaseStorage


protocol FullScreenScetionDelegate:class {
    
    func willDisplayPhoto(with reference:StorageReference, for user:(String,String))
    func willDisplayIndex(_ index:Int)
    
}

final class FullScreenPhotoSection: ListSectionController {
    
    private var photo:PhotoItem?
    weak var delegate:FullScreenScetionDelegate?
    
    override init() {
        super.init()
        displayDelegate = self
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width: CGFloat = collectionContext?.containerSize.width  ?? 0
        let height: CGFloat = collectionContext?.containerSize.height ?? 0
        return CGSize(width: width , height: height)
    }
    
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        if let cell = collectionContext?.dequeueReusableCell(withNibName:String(describing: FullScreenCell.self), bundle: Bundle.main, for: self, at: index) as? FullScreenCell {
            if let photo = photo{
                cell.setImage(photo)
            }
            
            return cell
        }
        return FullScreenCell()
    }
    
    override func didUpdate(to object: Any) {
        
        photo = object as? PhotoItem
    }
    
   
    
}


extension FullScreenPhotoSection: ListDisplayDelegate{
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
        if let photo = photo{
            let reference = Storage.reference(.userProfilePhotos).child(photo.userUid)
           
            delegate?.willDisplayPhoto(with: reference, for:(photo.userUid,photo.user))
        }
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
        //print("End display Cell")
    }
    
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        delegate?.willDisplayIndex(index)
        
        //print("The reference is \(reference)")
        //avatarImageview.sd_setImage(with: reference, placeholderImage: UIImage.placeholder)
    }
    
    func listAdapter(_ listAdapter: ListAdapter,
                     didEndDisplaying sectionController: ListSectionController,
                     cell: UICollectionViewCell,
                     at index: Int) {
        print("Did end displaying cell \(index) in section \(cell.debugDescription)")
    }
}



