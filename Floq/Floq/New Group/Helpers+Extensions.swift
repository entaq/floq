//
//  Helpers.swift
//  Floq
//
//  Created by Mensah Shadrach on 30/09/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit


func createDefaultAlert(_ title:String, _ message:String, _ style:UIAlertControllerStyle = .alert, _ actionTitle:String, _ actionStyle:UIAlertActionStyle = .default, _ handler: CompletionHandlers.alert?) -> UIAlertController{
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: style)
    let action = UIAlertAction(title: actionTitle, style: actionStyle, handler: handler)
    alert.addAction(action)
    return alert
}


enum CompletionHandlers{
    typealias alert = (_ alert:UIAlertAction) -> ()
    typealias dataservice = (_ data: Any?, _ errorMessage: String?) -> ()
    typealias nearbyCliqs = (_ cliq:FLCliqItem?, _ errorMessage:String?) -> ()
    typealias photos = (_ grids:[PhotoItem]?, _ errorMessage:String?) -> ()
    typealias photogrids = (_ grids:[GridPhotoItem]?, _ errorMessage:String?) -> ()
    
}



enum References:String{
    case users = "FLUSER"
    case floqs = "floq"
    case flocations = "FLLocations"
    case photos = "photos"
}

enum Fields:String{
    
    case username = "userName"
    case dateCreated = "dateCreated"
    case timestamp = "timestamp"
    case cliqname = "cliqName"
}


extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension UIColor{
    
    class func globalbackground() -> UIColor{
        return UIColor(red: 232/255, green: 232/255, blue: 240/255, alpha: 1)
    }
    
    class func barTint()-> UIColor{
        return UIColor(red: 41/255, green: 46/255, blue: 46/255, alpha: 1)
    }
    
}
