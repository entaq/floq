//
//  Helpers.swift
//  Floq
//
//  Created by Mensah Shadrach on 30/09/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit





extension UIAlertController{
    
    class func createDefaultAlert(_ title:String, _ message:String, _ style:UIAlertController.Style = .alert, _ actionTitle:String, _ actionStyle:UIAlertAction.Style = .default, _ handler: CompletionHandlers.alert?) -> UIAlertController{
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: actionTitle, style: actionStyle, handler: handler)
        alert.addAction(action)
        return alert
    }
}


enum CompletionHandlers{
    typealias alert = (_ alert:UIAlertAction) -> ()
    typealias dataservice = (_ data: Any?, _ errorMessage: String?) -> ()
    typealias nearbyCliqs = (_ cliq:FLCliqItem?, _ errorMessage:String?) -> ()
    typealias photos = (_ grids:[PhotoItem]?, _ errorMessage:String?) -> ()
    typealias photogrids = (_ grids:[GridPhotoItem]?, _ errorMessage:String?) -> ()
    typealias simpleBlock = ()->()
    typealias storage = (_ success:Bool, _ errorMessage:String?) -> ()
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
    
}

enum Fields:String{
    case fileID = "fileID"
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
}

enum keys:String{
    case near = "Near Me"
    case mine = "My Cliqs"
}



public enum Aliases{
    public typealias dictionary = Dictionary<String,Any>
    public typealias sset = Set<String>
    public typealias stuple = (String,String,Int)
    public typealias stray = Array<String>
    public typealias follower_set = Dictionary<String,Int>
}

enum InfoMessages:String{
    
    case nocliqs_nearby = "Oops, there are no cliqs nearby, try creating a cliq in this location"
    case nocliqs_for_me = "Oops, You have no cliqs, try adding some cliqs"
    
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
