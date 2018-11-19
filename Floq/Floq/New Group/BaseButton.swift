//
//  BaseNavigationController.swift
//  Floq
//
//  Created by Mensah Shadrach on 22/09/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit



class BaseBarButton:UIButton{
    
    
    private var label:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.backgroundColor = UIColor.clear.cgColor
        layer.cornerRadius = 3.0
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.3
        label = UILabel()
        label.text = "Join"
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.white
        label.frame = frame
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, title:String? = "Join") {
        self.init(frame: frame)
        label.text = title
    }
}


