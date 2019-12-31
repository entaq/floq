//
//  GradientView.swift
//  Floq
//
//  Created by Shadrach Mensah on 31/12/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//



import UIKit

class GradientView:UIView{
    
    private lazy var gradientLayer:CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.colors = colors
        gradient.locations = [0.25,0.25, 0]
        return gradient
    }()
    
    var colors = [UIColor.orangeyRed.cgColor,UIColor.seafoamBlue.cgColor, UIColor.pear.cgColor]
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    

    
    
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        layer.addSublayer(gradientLayer)
        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = [0.25,0.3, 0]
        gradientAnimation.toValue = [0.5,1,1]
        gradientAnimation.duration = 1
        gradientAnimation.repeatCount = .infinity
        gradientAnimation.autoreverses = true
        gradientAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        gradientLayer.add(gradientAnimation, forKey: nil)
    }
    
    func autoReverse()->Bool{
        let coll = [0,1]
        let rand = coll[Int(arc4random_uniform(UInt32(coll.count)))]
        return rand == 0
    }
    
    public override func layoutSubviews() {
         gradientLayer.frame = CGRect(x: -bounds.width, y: bounds.origin.y, width: 3 * bounds.width, height: bounds.height * 2)
        clipsToBounds = true
    }
    
    public override func removeFromSuperview() {
        //gradientLayer.removeAllAnimations()
        
    }

}
