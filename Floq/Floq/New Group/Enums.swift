//
//  Helpers.swift
//  Floq
//
//  Created by Mensah Shadrach on 30/09/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit


enum CompletionHandlers{
    typealias alert = (_ alert:UIAlertAction) -> ()
    typealias dataservice = (_ data: Any?, _ errorMessage: String?) -> ()
    typealias nearbyCliqs = (_ cliq:FLCliqItem?, _ errorMessage:String?) -> ()
    typealias photos = (_ grids:[PhotoItem]?, _ errorMessage:String?) -> ()
    typealias photogrids = (_ grids:[GridPhotoItem]?, _ errorMessage:String?) -> ()
    typealias simpleBlock = ()->()
    typealias storage = (_ success:Bool, _ errorMessage:String?) -> ()
    typealias notification = (_ id:String?) -> ()
}

enum ImageSizes:Int{
    case supermax = 32000000
    case max = 16000000
    case medium = 8000000
    case min = 4000000
}

enum Update:Int{
    case current = 3
    case leastSupport = 0
}



enum References:String{
    case users = "FLUSER"
    case floqs = "FLFLOQs"
    case flocations = "FLLocations"
    case photos = "Photos"
    case myCliqs = "Cliqs"
    case userProfilePhotos = "ProfilePhotos"
    case followers = "Followers"
    case storageFloqs = "FLFloqPhotos"
    case tokenRefs = "FLTOKENS"
    case utils = "FLUTILTY"
    case updateDoc = "Updates"
    case likes = "LIKES"
    case requestLikeShard = "LikesShard"
    
    
}

public enum Fields:String{
    
    case flagged, flaggers
    case fileID = "fileID"
    case cliqID = "cliqID"
    case username = "userName"
    case dateCreated = "dateCreated"
    case timestamp = "timestamp"
    case cliqname = "cliqName"
    case uid = "uid"
    case profileImg = "profileUrl"
    case userUID = "userID"
    case userEmail = "userEmail"
    case latestCliq = "latestCliq"
    case cliqCount = "cliqCount"
    case dateJoined = "dateJoined"
    case followers = "followers"
    case deleted = "deleted"
    case dateDeleted = "dateDeleted"
    case instanceToken = "instanceToken"
    case savedInstance =  "savedInstance"
    case current = "current"
    case info = "info"
    case least = "leastSupported"
    case forced = "forcedUpdateInfo"
    case likes = "likes"
    case likers = "likers"
    case maxxedLikes = "maxxedL"
    case shardLikes = "shards"
    case longitude = "longitude"
    case latitude = "latitude"
    case coordinate = "coordinate"
    case appurl = "appurl"
    case blockedMeList = "blockedMelist"
    case myblockingList = "myblockinglist"
}

public enum FLNotification:String{
    case added = "added"
    case modified = "modified"
    case removed = "removed"
    case cliqEntered = "cliqEntered"
    case cliqLeft = "cliqLeft"
    case myCliqsUpdated = "cliqsUpdated"
}

enum keys:String{
    case near = "Near Me"
    case mine = "My Cliqs"
    case active = "active"
    
}


public enum Aliases{
    public typealias dictionary = Dictionary<String,Any>
    public typealias sset = Set<String>
    public typealias stuple = (String,String,Int)
    public typealias stray = Array<String>
    public typealias follower_set = Dictionary<String,Int>
}

struct Info{
    enum Messages:String{
        case nocliqs_nearby = "Oops, there are no cliqs nearby, try creating a cliq in this location"
        case nocliqs_for_me = "Oops, You have no cliqs, try adding some cliqs"
        case not_aCliqMember = "You are unable to add photos because you have not joined this cliq yet. Join this cliq to add photos"
        case maxed_out_cliq = "You are unable to join. This cliq has reached its maximum capacity of followers"
    }

    enum Titles:String {
        case info = "INFO!!"
        case error = "Error"
        case success = "Success"
    }
    
    enum Action:String {
        case dismiss  = "Dismiss"
        case cancel = "Cancel"
        case ok = "OK"
        case delete = "Delete"
    }
}





enum DateFormats:String{
    case short_t = "MM-dd-yyyy HH:mm"
    case shirt_nt = "MM/dd/yyyy"
    case year_month = "MMMM yyyy"
    case month_day_year = "MMM d, yyyy"
    case long_epoch = "E, d MMM yyyy HH:mm:ss Z"
    case no_year_t = "MMM d, h:mm a"
    case no_year_nt = "MMM d"
}



