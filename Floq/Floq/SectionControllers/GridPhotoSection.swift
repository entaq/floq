//
//  GridPhotoSection.swift
//  Floq
//
//  Created by Mensah Shadrach on 16/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit
import IGListKit
import Firebase

protocol GridPhotoSectionDelegate:class {
    func didFinishSelecting(_ photo:PhotoItem, at index:Int)
}

final class GridPhotoSection: ListSectionController {
    
    private var gridItem: GridPhotoItem?
    var storageRef: StorageReference!
    weak var delegate:GridPhotoSectionDelegate?
    override init() {
        super.init()
        
        storageRef = Storage.floqPhotos
    }
    
    override func numberOfItems() -> Int {
        return gridItem?.count ?? 0
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width: CGFloat = collectionContext?.containerSize.width ?? 0
        let itemSize = floor(width / 4)
        return CGSize(width: itemSize, height: itemSize)
    }
    
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        if let cell = collectionContext?.dequeueReusableCell(withNibName:String(describing: PhotoCell.self), bundle: Bundle.main, for: self, at: index) as? PhotoCell {
            let photoItem = gridItem?.items[index]
            let reference = storageRef.child(photoItem?.fileID ?? "")
            cell.configureCell(ref: reference, photoID: photoItem!.id)
            return cell
        }
        return ImageCell()
    }
    
    override func didUpdate(to object: Any) {
        self.gridItem = object as? GridPhotoItem ??  GridPhotoItem(items: [])
    }
    
    override func didSelectItem(at index: Int) {
        if let item = gridItem{
            let photo = item.items[index]
            delegate?.didFinishSelecting(photo, at: index)
        }
    }
}
