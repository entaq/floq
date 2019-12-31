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
    
    func signIn(){
        if let authVc = UIStoryboard.main.instantiateViewController(withIdentifier: AuthenticationVC.identifier) as? AuthenticationVC{
            authVc.modalPresentationStyle = .fullScreen
            present(authVc, animated: true, completion: nil)
        }
    }
    
}


class OnBoardingPageOne:BaseOnBoarding{
    
    @IBOutlet weak var headerToSignInConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         let handle = UIScreen.main.screenType()
        if handle == .eight_lower{
            headerToSignInConstraint.constant = 10
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pager?.currentPage = 0
    }
    
    @IBAction func signInPressed(_ sender:UIButton){
        signIn()
    }
    
}

class OnBoardingPageTwo:BaseOnBoarding{
    
     @IBOutlet weak var headerToSignInConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         let handle = UIScreen.main.screenType()
        if handle == .eight_lower{
            headerToSignInConstraint.constant = 10
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pager?.currentPage = 1
    }
    
    @IBAction func signInPressed(_ sender:UIButton){
        signIn()
    }
    
}

class OnBoardingPageThree:BaseOnBoarding{
    
    @IBOutlet weak var headerToSignInConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         let handle = UIScreen.main.screenType()
        if handle == .eight_lower{
            headerToSignInConstraint.constant = 10
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pager?.currentPage = 2
    }
    
    @IBAction func signInPressed(_ sender:UIButton){
        signIn()
    }
    
}

class OnBoardingPageFour:BaseOnBoarding{
    
    @IBOutlet weak var headerToSignInConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         let handle = UIScreen.main.screenType()
        if handle == .eight_lower{
            headerToSignInConstraint.constant = 10
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pager?.currentPage = 3
    }
    
    @IBAction func signInPressed(_ sender:UIButton){
        signIn()
    }
    
}
