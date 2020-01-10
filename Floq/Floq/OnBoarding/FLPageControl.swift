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
            customizePageControl()
        }
    }
    
    var selector:Selector?

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
                //image.frame.origin.y -= 5
                //image.frame.origin.x -= 3
                
                endView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }
        }
    }

}
