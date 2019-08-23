//
//  App.swift
//  Floq
//
//  Created by Shadrach Mensah on 23/08/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import Foundation

struct App {
    
    enum Domain{
        case Home, AddCliq,Profile,BlockedUsers,Eula,My_Cliqs,Nearby,Photos,FullScreenPhoto,Comment
    }
    
    static var user:FLUser?{
        return (UIApplication.shared.delegate as! AppDelegate).appUser
    }
    
    static var currentDomain:Domain = .Home
}
