//
//  PhotoItem.swift
//  Floq
//
//  Created by Arun Nagarajan on 12/10/17.
//  Copyright © 2017 Arun Nagarajan. All rights reserved.
//
import IGListKit

final class PhotoItem: ListDiffable, Equatable {
    static func ==(lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        return lhs.photoID == rhs.photoID && lhs.user == rhs.user
    }
    
    let photoID: String
    let user: String
    let timestamp:Date
    
    init(photoID: String, user: String, timestamp:Date) {
        self.photoID = photoID
        self.user = user
        self.timestamp = timestamp
    }
    
    // MARK: ListDiffable
    
    func diffIdentifier() -> NSObjectProtocol {
        return photoID as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? PhotoItem else { return false }
        return user == object.user
    }
    
}
