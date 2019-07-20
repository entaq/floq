//
//  SmartAlertView.swift
//  Floq
//
//  Created by Shadrach Mensah on 20/07/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class SmartAlertView: UIView {

    private lazy var textlable:UILabel = {
        let lab = UILabel(frame:.zero)
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.textColor = .white
        lab.numberOfLines = 1
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(text:String){
        let frame = CGRect(x: 20, y: -100, width: UIScreen.width - 40, height: 40)
        super.init(frame: frame)
        backgroundColor = .seafoamBlue
        clipsToBounds = true
        layer.cornerRadius = 20
        addSubview(textlable)
        textlable.text = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textlable.layout{
            $0.leading == leadingAnchor + 12
            $0.centerY == centerYAnchor
        }
    }
    
    func show(){
        if let view = UIApplication.shared.keyWindow{
            view.addSubview(self)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.4, options: .curveEaseInOut, animations: {
                self.frame.origin.y = 80
            }) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(4), execute: {
                    UIView.animate(withDuration: 0.6, animations: {
                        self.frame.origin.y = -100
                    }){_ in self.removeFromSuperview()}
                })
            }
        }
    }
    
}
