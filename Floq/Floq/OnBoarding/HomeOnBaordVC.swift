
//
//  HomeOnBaordVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 05/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class HomeOnBaordVC:UIViewController {
    
    @IBOutlet weak var flamimgoGroup: UIImageView!
    
    
    var scale:CGFloat = 105 / 306
    var heightScale:CGFloat = 0
    
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControl: FLPageControl!
    private var onBoardPage:UIPageViewController!
    
    let ids = [
        OnBoardingPageOne.identifier,
        OnBoardingPageTwo.identifier,
        OnBoardingPageThree.identifier,
        OnBoardingPageFour.identifier,
        AuthenticationVC.identifier
        
    ]
    
    fileprivate lazy var pages: [UIViewController] = {
        let controllers:[UIViewController] = ids.compactMap{
            let controller = getViewController(withIdentifier: $0)
            (controller as? BaseOnBoarding)?.pager = pageControl
            (controller as? BaseOnBoarding)?.pageController = onBoardPage
            return controller
        }
        controllers.forEach {
            if let vc = $0 as? BaseOnBoarding{
                vc.signInViewController = controllers.last
            }else if let vc = $0 as? AuthenticationVC{
                vc.pager = pageControl
            }
        }
        return controllers
    }()
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController
    {
        return UIStoryboard.main.instantiateViewController(withIdentifier: identifier)
    }
    
    
    @objc func  moveToSignIn(){
        (pages.first as? BaseOnBoarding)?.signIn()
    }
    

    func configScale(){
        let handle = UIScreen.main.screenType()
        
        switch handle {
        case .xmax_xr:
            heightScale = 0.55
            return
        case .xs_x:
            heightScale = 0.50
            return
        case .pluses:
            heightScale = 0.50
            return
        case .eight_lower:
            heightScale = 0.50
        default:
            heightScale = 0.45
            return
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        App.setDomain(.Onboarding)
        
        pageControl.removeFromSuperview()
        pageControl.transform = CGAffineTransform(scaleX: 2, y: 2)
        onBoardPage = 
            UIStoryboard.main.instantiateViewController(withIdentifier: OnBoardingPVC.identifier) as? OnBoardingPVC
        onBoardPage.dataSource = self
        onBoardPage.delegate = self
        onBoardPage.setViewControllers([pages.first!], direction: .forward, animated: false, completion: nil)
        onBoardPage.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        add(onBoardPage, to: self.view)
        view.addSubview(pageControl)
        pageControl.layout{
            $0.centerX == view.centerXAnchor
            $0.centerY == view.centerYAnchor + 10
        }
        pageControl.addAcction(selector: #selector(moveToSignIn))
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        onBoardPage.view.frame = CGRect(x:0, y:0, width:self.view.frame.size.width, height:self.view.frame.size.height)
    }
    

    

}


extension HomeOnBaordVC:UIPageViewControllerDataSource,UIPageViewControllerDelegate{
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        //pageControl.currentPage = pages.index(of: viewController)!
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0          else { return nil }
        
        guard pages.count > previousIndex else { return nil        }
        //pageControl.currentPage = previousIndex
        return pages[previousIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        //pageControl.currentPage = pages.index(of: viewController)!
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return nil }
        
        guard pages.count > nextIndex else { return nil         }
        
        return pages[nextIndex]
    }
    

    

}
