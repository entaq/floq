//
//  OnBoardingPVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 05/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class OnBoardingPVC: UIPageViewController{
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let subViews: NSArray = view.subviews as NSArray
        var scrollView: UIScrollView? = nil
        var pageControl: UIPageControl? = nil
        
        for view in subViews {
            if (view as AnyObject) is (UIScrollView) {
                scrollView = view as? UIScrollView
            }
            else if (view as AnyObject) is (UIPageControl) {
                pageControl = view as? UIPageControl
            }
        }
        
        if (scrollView != nil && pageControl != nil) {
            scrollView?.frame = view.bounds
            view.bringSubviewToFront(pageControl!)
        }
    
    }


//    fileprivate lazy var pages: [UIViewController] = {
//        return [
//            self.getViewController(withIdentifier: OnBoardInfoOneVC.identifier),
//            self.getViewController(withIdentifier: OnBoardInfoTwoVC.identifier)
//        ]
//    }()
//
//    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController
//    {
//        return UIStoryboard.main.instantiateViewController(withIdentifier: identifier)
//    }




    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
