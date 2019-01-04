//
//  File.swift
//  Floq
//
//  Created by Mensah Shadrach on 04/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import  IGListKit



final class ActiveSectionController:ListSectionController{
    
    private var sectionClq:SectionableCliq?
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width: CGFloat = collectionContext?.containerSize.width  ?? 0
        
        return CGSize(width: width , height: 50)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        <#code#>
    }
    
    override func didUpdate(to object: Any) {
        sectionClq = object as? SectionableCliq
    }
}
