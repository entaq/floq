
//
//  HomeOnBaordVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 05/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class HomeOnBaordVC:UIViewController {
    
    lazy var fetherView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    var scale:CGFloat = 105 / 306
    var heightScale:CGFloat = 0
    
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    private var onBoardPage:UIPageViewController!
    
    fileprivate lazy var pages: [UIViewController] = {
        return [
            self.getViewController(withIdentifier: OnBoardInfoOneVC.identifier),
            self.getViewController(withIdentifier: OnBoardInfoTwoVC.identifier)
        ]
    }()
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController
    {
        return UIStoryboard.main.instantiateViewController(withIdentifier: identifier)
    }
    
    func configureDevice(){
        //view.addSubview(fetherView)
        configScale()
        if UIScreen.main.bounds.height > 740{
            topLayoutConstraint.constant = 60
            fetherView.image = UIImage(named: "Featherxlarge")
            //scale = fetherView.image!.scale
        }else{
            topLayoutConstraint.constant = 30
            fetherView.image = UIImage(named: "featherLarge")
            //scale = fetherView.image!.scale
        }
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
        configureDevice()
        pageControl.transform = CGAffineTransform(scaleX: 2, y: 2)
        fetherView.translatesAutoresizingMaskIntoConstraints = false
        onBoardPage = 
            UIStoryboard.main.instantiateViewController(withIdentifier: OnBoardingPVC.identifier) as? OnBoardingPVC
        onBoardPage.dataSource = self
        onBoardPage.delegate = self
        onBoardPage.setViewControllers([pages.first!], direction: .forward, animated: false, completion: nil)
        onBoardPage.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        add(onBoardPage, to: self.view)
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        onBoardPage.view.frame = CGRect(x:0, y:0, width:self.view.frame.size.width, height:self.view.frame.size.height)
        let height = view.bounds.height * heightScale
        /*NSLayoutConstraint.activate([
            fetherView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            fetherView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fetherView.heightAnchor.constraint(equalToConstant: height),
            fetherView.widthAnchor.constraint(equalToConstant: height * scale)
        ])*/
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}


extension HomeOnBaordVC:UIPageViewControllerDataSource,UIPageViewControllerDelegate{
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        pageControl.currentPage = pages.index(of: viewController)!
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0          else { return nil }
        
        guard pages.count > previousIndex else { return nil        }
        pageControl.currentPage = previousIndex
        return pages[previousIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        pageControl.currentPage = pages.index(of: viewController)!
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return nil }
        
        guard pages.count > nextIndex else { return nil         }
        
        return pages[nextIndex]
    }
    

   

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
//        let vc = pendingViewControllers.first!
//        let index = pages.index(of: vc)
//        pageControl.currentPage = index!
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let vc = previousViewControllers.first!
        let index = pages.index(of: vc)
        pageControl.currentPage = index!
    }
    

}
