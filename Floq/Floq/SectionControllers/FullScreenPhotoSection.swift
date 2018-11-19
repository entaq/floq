//
//  FullScreenPhotoSection.swift
//  Floq
//
//  Created by Mensah Shadrach on 17/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit
import IGListKit
import Firebase

final class FullScreenPhotoSection: ListSectionController {
    
    private var photo:PhotoItem?
    
    
    override init() {
        super.init()
        
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

