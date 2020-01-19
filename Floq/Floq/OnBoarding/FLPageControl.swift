//
//  FLPageControl.swift
//  Floq
//
//  Created by Shadrach Mensah on 31/12/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit



class FLPageControl: UIPageControl {

    
    override var currentPage: Int{
        didSet{
            animatePagers()
            customizePageControl()
        }
    }
    
    
    
    var selector:Selector?
    var canShowPager = false

    override func awakeFromNib() {
        super.awakeFromNib()
        customizePageControl()
    }
    
    func addAcction(selector:Selector){
        addTarget(self, action:#selector(performAtLast), for: .touchUpInside)
    }
    
    @objc func performAtLast(){
        if let selector = selector, currentPage == numberOfPages - 2{
            performSelector(onMainThread: selector, with: nil, waitUntilDone: true)
        }
    }
    
    func customizePageControl(){
        if let endView = subviews.last{
            endView.backgroundColor = .clear
            if endView.subviews.first as? UIImageView == nil{
                let image = UIImageView(frame: CGRect(origin: .zero, size: endView.frame.size))
                image.image = #imageLiteral(resourceName: "enpage")
                image.contentMode = .scaleAspectFit
                endView.addSubview(image)
                
                endView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }
        }
    }

    func animatePagers(){
        if currentPage == 4{
            canShowPager = true
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                self.alpha = 0
            }, completion: nil)
        }else{
            if canShowPager{
                canShowPager = false
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                        self.alpha = 1
                }, completion: nil)
            }
        }
    }
}

