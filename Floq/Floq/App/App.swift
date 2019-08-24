//
//  App.swift
//  Floq
//
//  Created by Shadrach Mensah on 23/08/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import Firebase

struct App {
    
    enum Domain{
        case Home, AddCliq,Profile,BlockedUsers,Eula,My_Cliqs,Nearby,Photos,FullScreenPhoto,Comment, UserList, Onboarding, FinalOnboard
    }
    
    static var user:FLUser?{
        return (UIApplication.shared.delegate as! AppDelegate).appUser
    }
    
    static private var _currentDomain:Domain = .Home
    
    static private var _signInMethod:EULAVC.SignInMethod = .none
    
    static func setDomain(_ domain:Domain){
        _currentDomain = domain
    }
    
    static var currentDomain:Domain{
        return _currentDomain
    }
    
    static func setMethod(_ method:EULAVC.SignInMethod){
        _signInMethod = method
    }
    
    static var signInMethod:EULAVC.SignInMethod{
        return _signInMethod
    }
    
    
}




extension App{
    
    static func congigure(){
        #if DEBUG
        print("this is a debug build")
        #else
        print("Hell Yeah We in production")
        #endif
    }
}
