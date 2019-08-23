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
        case Home, AddCliq,Profile,BlockedUsers,Eula,My_Cliqs,Nearby,Photos,FullScreenPhoto,Comment, UserList, Onboarding, FinalOnboard
    }
    
    static var user:FLUser?{
        return (UIApplication.shared.delegate as! AppDelegate).appUser
    }
    
    static private var _currentDomain:Domain = .Home
    
    static func setDomain(_ domain:Domain){
        _currentDomain = domain
    }
    
    static var currentDomain:Domain{
        return _currentDomain
    }
}
