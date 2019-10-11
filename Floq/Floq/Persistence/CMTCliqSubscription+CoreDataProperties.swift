//
//  CMTCliqSubscription+CoreDataProperties.swift
//  
//
//  Created by Shadrach Mensah on 19/08/2019.
//
//

import Foundation
import CoreData


extension CMTCliqSubscription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMTCliqSubscription> {
        return NSFetchRequest<CMTCliqSubscription>(entityName: "CMTCliqSubscription")
    }

    @NSManaged public var cliqID: String?
    @NSManaged public var count: Int64
    @NSManaged public var photoSubscriptions: NSSet?
    
    

}

// MARK: Generated accessors for photoSubscriptions
extension CMTCliqSubscription {

    @objc(addPhotoSubscriptionsObject:)
    @NSManaged public func addToPhotoSubscriptions(_ value: CMTPhotoSubscription)

    @objc(removePhotoSubscriptionsObject:)
    @NSManaged public func removeFromPhotoSubscriptions(_ value: CMTPhotoSubscription)

    @objc(addPhotoSubscriptions:)
    @NSManaged public func addToPhotoSubscriptions(_ values: NSSet)

    @objc(removePhotoSubscriptions:)
    @NSManaged public func removeFromPhotoSubscriptions(_ values: NSSet)

}
