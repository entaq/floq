//
//  FLCliqsModeller.swift
//  Floq
//
//  Created by Mensah Shadrach on 31/12/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import IGListKit



class  SectionableCliq:ListDiffable, Equatable{
    
    func diffIdentifier() -> NSObjectProtocol {
        return sectionType.hashValue as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? SectionableCliq else { return false }
        return sectionType == object.sectionType
    }
    
    static func == (lhs: SectionableCliq, rhs: SectionableCliq) -> Bool {
        return rhs.sectionType.hashValue == lhs.sectionType.hashValue
    }
    
    
    func update(_ cliq:FLCliqItem){
        if !cliqs.contains(cliq){
            cliqs.append(cliq)
        }
    }
    
    
    public  var cliqs:[FLCliqItem]
    public private (set) var sectionType:keys
    public private (set) var designatedIndex:Int
    private var cliqcount:Int?
    func getFirstItem()->FLCliqItem{
        return cliqs.first!
    }
    
    
    func count()->Int{
        return cliqcount ?? cliqs.count
    }
    
    func setCount(_ count:Int?){
        cliqcount = count
    }
    
    init(cliqs:[FLCliqItem],type:keys,count:Int? = nil) {
        self.cliqs = cliqs
        sectionType = type
        self.cliqcount = count
        switch type {
        case .active:
            designatedIndex = 0
            break
        case .near:
            designatedIndex = 1
            break
        default:
            designatedIndex = 2
            break
        }
    }
}
