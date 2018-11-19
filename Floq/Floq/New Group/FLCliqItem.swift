//
//  FLCliqItem.swift
//  Floq
//
//  Created by Mensah Shadrach on 15/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import IGListKit

class FLCliqItem:ListDiffable, Equatable{
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    
    static func ==(lhs: FLCliqItem, rhs: FLCliqItem) -> Bool {
        return lhs.id == rhs.id && lhs.item == rhs.item
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? FLCliqItem else { return false }
        return id == object.id
    }
    
    private let id:String
    private let item:PhotoItem
    private let name:String
    
    var itemID:String{
        get{
            return id
        }
    }
    
    var photoItem:PhotoItem{
        get{
            return item
        }
    }
    
    var cliqname:String{
        get{
            return name
        }
    }
    
    init(id:String,name:String, item:PhotoItem) {
        self.id = id
        self.item = item
        self.name = name
    }
    
}
