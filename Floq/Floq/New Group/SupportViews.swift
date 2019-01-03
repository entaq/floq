//
//  SupportViews.swift
//  Floq
//
//  Created by Mensah Shadrach on 18/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit


class ContainerView:UIView{
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5.0
        layer.shadowRadius = 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }
}


class FButton:UIButton{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.cornerRadius = 3.0
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.3
    }
}


class LoaderView:UIView{
    
    var activity:UIActivityIndicatorView!
    var label:UILabel!
    override init(frame: CGRect) {
        super.init(frame:frame)
        backgroundColor = UIColor.darkText
        alpha = 0.75
        activity = UIActivityIndicatorView(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
        activity.center = CGPoint(x: center.x, y: center.y - 100)
        addSubview(activity)
        activity.style = .whiteLarge
        label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: frame.width - 32, height: 40)))
        label.center = center
        label.backgroundColor = .clear
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.text = "Loading, Please wait.."
        
        addSubview(label)
        activity.startAnimating()
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SeperatorCell:UICollectionViewCell{
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AvatarImageView:UIImageView{
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonSetup()
    }
    
    func commonSetup(){
        layer.cornerRadius = frame.width / 2
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        clipsToBounds = true
        contentMode = .scaleAspectFill
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
