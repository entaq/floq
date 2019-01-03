//
//  UIKitModules+Extensions.swift
//  Floq
//
//  Created by Mensah Shadrach on 01/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit


extension UIViewController{
    
    func add(_ child: UIViewController, to parentView:UIView? = nil) {
        addChild(child)
        if let v = parentView{
            v.addSubview(child.view)
        }else{
            view.addSubview(child.view)
        }
        child.didMove(toParent: self)
    }
    func removeFrom() {
        guard parent != nil else {
            return
        }
        
        willMove(toParent: nil)
        removeFromParent()
        
        view.removeFromSuperview()
    }
}

extension UIView{
    
    class func listAdapterEmptyView(superView:UIView, info:InfoMessages)->UIView{
        let view = UIView(frame: superView.frame)
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: view.frame.height)))
        label.numberOfLines = 10
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.text = info.rawValue
        label.center = view.center
        view.addSubview(label)
        return view
    }
}


extension UIImage{
    
    public static var placeholder:UIImage{
        return UIImage(named: "imageplaceholder")!
    }
    
    public static var icon_menu:UIImage{
        return UIImage(named: "icon_account")!
    }
    
    public static var icon_addPhoto:UIImage{
        return UIImage(named: "addphoto")!
    }
    
    
}

extension UIColor{
    
    public static var globalbackground:UIColor{
        return UIColor(red: 232/255, green: 232/255, blue: 240/255, alpha: 1)
    }
    
    public static var barTint:UIColor{
        return UIColor(red: 41/255, green: 46/255, blue: 46/255, alpha: 1)
    }
    
}

