//
//  OnBoardingControllers.swift
//  Floq
//
//  Created by Shadrach Mensah on 31/12/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class BaseOnBoarding:UIViewController{
    
    weak  var pager:UIPageControl?
    
}


class OnBoardingPageOne:BaseOnBoarding{
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pager?.currentPage = 0
    }
    
}

class OnBoardingPageTwo:BaseOnBoarding{
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pager?.currentPage = 1
    }
    
}

class OnBoardingPageThree:BaseOnBoarding{
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pager?.currentPage = 2
    }
    
}

class OnBoardingPageFour:BaseOnBoarding{
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pager?.currentPage = 3
    }
    
}
