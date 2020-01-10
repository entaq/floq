//
//  Alerts.swift
//  Floq
//
//  Created by Shadrach Mensah on 13/08/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit



struct AlertSystem{
    static var _TYPE = "type"
    enum Types {
    static let USER_JOINED = "jd";
    static let PHOTO_ADDED = "pa";
    static let COMMENT_ADDED = "ca";
    static let PHOTO_LIKED = "pl";
    
    }
}
    
public class SnackBar: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public class func makeSnackIn(_ parent:UIView, text:String, color:UIColor? = nil){
        let snackbar = SnackBar(frame: CGRect(x: 10, y: parent.frame.height, width: parent.frame.width - 20, height: 50))
        snackbar.backgroundColor = color ?? .seafoamBlue
        parent.addSubview(snackbar)
        snackbar.dropCorner(8)
        snackbar.dropShadow()
        let label = UILabel(frame: CGRect(x: 12, y: 0, width: parent.frame.width, height: 50))
        snackbar.addSubview(label)
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.backgroundColor = .clear
        label.text = text
        UIView.animate(withDuration: 1, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            snackbar.frame.origin.y -= 100
        })
        UIView.animate(withDuration: 0.5, delay: 6, options: .curveEaseOut, animations: {
            snackbar.frame.origin.y += 100
        }) { (success) in
            snackbar.removeFromSuperview()
        }
    }
    
    public class func makeSncakMessage(text:String, color:UIColor? = nil){
        guard let view = UIApplication.shared.keyWindow else {return}
        makeSnackIn(view, text: text, color: color ?? .seafoamBlue)
    }
}

