//
//  PhotoFullScreenVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 17/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit
import IGListKit

class PhotoFullScreenVC: UIViewController {

    var allphotos:[PhotoItem]!
    var selectedIndex:Int = 0
    
    
    init(allphotos:[PhotoItem], selected index:Int){
        self.allphotos =  allphotos
        self.selectedIndex = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 2)
    }()
    
    
    lazy var avatarImageview:UIImageView = {
        let imgv = UIImageView()
        imgv.clipsToBounds = true
        imgv.contentMode = .scaleAspectFill
        return imgv
    }()
    
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let butt = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        navigationItem.rightBarButtonItem = butt
        view.addSubview(collectionView)
        collectionView.isPagingEnabled = true
    }
    
    @objc func share(){
        present(createDefaultAlert("INFO", "SHARED!!",.alert, "Dismiss",.cancel, nil), animated:true, completion: nil)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        setAvatarView()
        collectionView.backgroundColor = UIColor.globalbackground()
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.reloadData(completion: nil)
        let obj = allphotos[selectedIndex]
        adapter.scroll(to: obj, supplementaryKinds: nil, scrollDirection: .horizontal, scrollPosition: .centeredHorizontally, animated: false)
    }
    
    func setAvatarView(){
        avatarImageview.frame =  CGRect(x: self.view.center.x - 35, y: 30, width: 70, height: 70)
        avatarImageview.backgroundColor = UIColor.white
        avatarImageview.layer.cornerRadius = 35
        avatarImageview.layer.borderWidth = 2.0
        avatarImageview.layer.borderColor = UIColor.white.cgColor
        avatarImageview.image = UIImage(named: "addcliq")
        self.navigationController?.view.addSubview(avatarImageview)


        

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        avatarImageview.removeFromSuperview()
    }
}


extension PhotoFullScreenVC:ListAdapterDataSource{
    
    
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        
        return allphotos as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return FullScreenPhotoSection()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {

        return nil
    }

}

