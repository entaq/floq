//
//  Identity.swift
//  Floq
//
//  Created by Shadrach Mensah on 10/01/2020.
//  Copyright © 2020 Arun Nagarajan. All rights reserved.
//

import Foundation

protocol Identity{
    static var Identifier:String {get}
}


extension Identity{
    static var Identifier:String{
        if XCODE{
            
        }
        return "\(Self.self)"
    }
}
