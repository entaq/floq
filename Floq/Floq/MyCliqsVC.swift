//
//  MyCliqsVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 02/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import IGListKit
import Floaty

class MyCliqsVC: UIViewController {
    
    private var photoEngine:PhotoEngine!
    
    lazy var adapter:ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 2)
    }()
    
        private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    init(engine:PhotoEngine) {
        super.init(nibName: nil, bundle: nil)
        photoEngine = engine
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Cliqs"
        let floaty = Floaty()
        floaty.buttonColor = .clear
        floaty.buttonImage = UIImage(named: "page1")
        
        floaty.addItem("Create a Cliq", icon: UIImage(named: "AppIcon")!, handler: { item in
            self.present(AddCliqVC(), animated: true, completion: nil)
        })
        view.addSubview(floaty)
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        collectionView.backgroundColor = UIColor.globalbackground
        view.addSubview(collectionView)
        
        let barbutt = UIBarButtonItem(image: .icon_menu, style: .plain, target: self, action: #selector(accountMenuTapped))
        navigationItem.rightBarButtonItem = barbutt
        
    }
    
    
    @objc func accountMenuTapped(){
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        if let vc = storyboard.instantiateViewController(withIdentifier: String(describing: UserProfileVC.self)) as? UserProfileVC{
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        adapter.collectionViewDelegate = self
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    
    
    


}



extension MyCliqsVC:ListAdapterDataSource,UICollectionViewDelegate{
    
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return photoEngine.myCliqs as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return PhotoSection(isHome: false, keys:.mine)
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return .listAdapterEmptyView(superView: self.view, info: .nocliqs_for_me)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cliq = photoEngine.myCliqs[indexPath.section]
        self.navigationController?.pushViewController(PhotosVC(cliq: cliq), animated: true)
    }
}
