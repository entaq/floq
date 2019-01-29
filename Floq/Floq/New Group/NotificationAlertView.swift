//
//  NotificationAlertView.swift
//  Floq
//
//  Created by Mensah Shadrach on 29/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit


class NotificationAlertView:UIView{
    
    var titleLabel:UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    var subtitlelabel:UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    var method:CompletionHandlers.notification?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.seafoamBlue
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 16, y: 25, width: frame.width, height: 20)
        subtitlelabel.frame = CGRect(x: 16, y: 45, width: frame.width - 16, height: 40)
        self.addSubview(titleLabel)
        addSubview(subtitlelabel)
        let tap = UITapGestureRecognizer(target: self, action: #selector(response))
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)
    }
    
    @objc func response(){
        method?(nil)
        self.removeFromSuperview()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            self.frame.origin.x = 0
        }) { (success) in
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6), execute: {
            UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut, animations: {
                self.frame.size.height = -200
            }, completion: { (succes) in
                self.removeFromSuperview()
            })
        })
    }
    
}
