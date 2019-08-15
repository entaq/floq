//
//  CliqsVC.swift
//  Floq
//
//  Created by Arun Nagarajan on 7/8/18.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit
import IGListKit
import Firebase

import CoreLocation
import SDWebImage




final class HomeVC : UIViewController {
    
    var refreshControl:UIRefreshControl!
    var  fluser:FLUser?
    var isFetchingNearby = false
    var allCliqs:[SectionableCliq] = []

    private var locationManager:CLLocationManager!
    private var queryhandle:GFSQueryHandle?
    var globalEngine:CliqEngine{
        return (UIApplication.shared.delegate as! AppDelegate).mainEngine
    }
    
    var myCliqCount:Int{
        return (UIApplication.shared.delegate as! AppDelegate).appUser?.cliqs ?? 0
    }
    
    lazy var collectionView:UICollectionView = {
        let col = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        col.showsVerticalScrollIndicator = false
        return col
    }()
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 2)
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let app = UIApplication.shared.delegate as? AppDelegate{
            app.registerRemoteNotifs(app: UIApplication.shared)
        }
        finishRegistrations()
        setup()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        title = "Floq"
        globalEngine.setMostActive()
        updateData()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    
    @objc func updateNearby(){
        self.adapter.reloadData(completion: nil)
    }
    
    
    
    @objc func updateData(){
        self.adapter.reloadData(completion: nil)
        if refreshControl.isRefreshing{
            refreshControl.endRefreshing()
        }
    }
    
    
    func setup(){
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        collectionView.backgroundColor = UIColor.globalbackground
        let floaty = Floaty()
        floaty.buttonColor = .clear
        floaty.buttonImage = .icon_app_rounded
        
        floaty.addItem("Create a Cliq", icon:.icon_app, handler: { item in
            self.present(AddCliqVC(), animated: true, completion: nil)
        })
        
        floaty.addItem("Profile", icon:.placeholder, handler: { item in
            if let vc = UIStoryboard.main.instantiateViewController(withIdentifier: String(describing: UserProfileVC.self)) as? UserProfileVC{
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        view.addSubview(collectionView)
        
        
        view.addSubview(floaty)
        adapter.collectionViewDelegate = self
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
    }
    
    
    func finishRegistrations(){
        NotificationCenter.set(observer: self, selector: #selector(updateNearby), name: .cliqEntered)
        NotificationCenter.set(observer: self, selector: #selector(updateData), name: .myCliqsUpdated)
        NotificationCenter.set(observer: self, selector: #selector(updateNearby), name: .cliqLeft)
    }
    
    func removeRegistrations(){
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeRegistrations()
    }
    
}


extension HomeVC: UICollectionViewDelegate, ListAdapterDataSource{
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        
        return globalEngine.homeData as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if let sect =  object as? SectionableCliq{
            if sect.sectionType == .active{
                return ActiveSectionController()
            }
        }
        return PhotoSection(isHome: true)
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        
        return .listAdapterEmptyView(superView: view, info: .nocliqs_nearby)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cliqsction = globalEngine.homeData[indexPath.section]
        switch cliqsction.sectionType {
        case .active:
            let vc = PhotosVC(cliq: cliqsction.cliqs.first!, id: cliqsction.cliqs.first!.id)
            navigationController?.pushViewController(vc, animated: true)
            break
        case .near:
            let vc = NearbyCliqsVC(data: cliqsction.cliqs)
            navigationController?.pushViewController(vc, animated: true)
            break
        case .mine:
            let vc = MyCliqsVC()
            navigationController?.pushViewController(vc, animated: true)
            break

        }
        
    
   }
    

}

