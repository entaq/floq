//
//  CMTPhotoSubscription+CoreDataProperties.swift
//  
//
//  Created by Shadrach Mensah on 19/08/2019.
//
//

import Foundation
import CoreData


extension CMTPhotoSubscription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMTPhotoSubscription> {
        return NSFetchRequest<CMTPhotoSubscription>(entityName: "CMTPhotoSubscription")
    }

    @NSManaged public var canBroadcast: Bool
    @NSManaged public var count: Int64
    @NSManaged public var lastTimestamp: Int64
    @NSManaged public var photoID: String?
    @NSManaged public var parentCliqSub: CMTCliqSubscription?

}
