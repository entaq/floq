//
//  GridPhotoItem.swift
//  Floq
//
//  Created by Mensah Shadrach on 17/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

/**
 INFO:
 Wrapper class to wrap the photoItems into a an array with max capacity of 4
 for convenience dispaly in a section
 */
import Foundation
import IGListKit

final class GridPhotoItem:NSObject, ListDiffable{
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
    
    private var _items:[PhotoItem] = []
    private var _count:Int = 0
    private var _isFilled:Bool = false
    
    var items:[PhotoItem]{
        return _items
    }
    
    var count:Int{
        return _count
    }
    
    var isFilled:Bool{
        return _isFilled
    }
    
    init(items:[PhotoItem]) {
         super.init()
        _items = items
        _count = items.count
        if _count > 3 {
            _isFilled = true
        }
        
    }
    
    
    
}
