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
import Floaty
import CoreLocation
import SDWebImage
import Geofirestore


final class HomeVC : UIViewController {
    
    
    var  fluser:FLUser?
    var isFetchingNearby = false
    var allCliqs:[SectionableCliq] = []
    var nearbyScliq:SectionableCliq?
    var mySectionalCliqs:SectionableCliq?
    var myActiveSectionCliq:SectionableCliq?
    private var locationManager:CLLocationManager!
    private var queryhandle:GFSQueryHandle?
    var globalEngine:PhotoEngine{
        return (UIApplication.shared.delegate as! AppDelegate).photoEngine
    }
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
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
        if globalEngine.activeCliq != nil{
            globalEngine.setMostActive()
            updateData()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    
    @objc func updateNearby(){
        if self.nearbyScliq == nil{
            self.nearbyScliq = SectionableCliq(cliqs: self.globalEngine.nearbyCliqs, type: .near)
            self.allCliqs.append(self.nearbyScliq!)
        }else{
            self.nearbyScliq!.cliqs = self.globalEngine.nearbyCliqs
        }
        self.allCliqs.sort { (s1, s2) -> Bool in
            return s1.designatedIndex < s2.designatedIndex
        }
        self.adapter.reloadData(completion: nil)
    }
    
    
    
    @objc func updateData(){
        if mySectionalCliqs != nil{
            mySectionalCliqs!.cliqs = self.globalEngine.myCliqs
        }else{
            mySectionalCliqs = SectionableCliq(cliqs: globalEngine.myCliqs, type: .mine)
            allCliqs.append(mySectionalCliqs!)
        }
        if myActiveSectionCliq != nil{
            if globalEngine.activeCliq != nil{
                if globalEngine.activeCliq!.id != myActiveSectionCliq!.cliqs.first!.id{
                    myActiveSectionCliq?.cliqs = [globalEngine.activeCliq!]
                }else{
                    //There is no more active cliq.. Remove that section
                    
                }
            }
        }else{
            if self.globalEngine.activeCliq != nil{
                myActiveSectionCliq = SectionableCliq(cliqs: [globalEngine.activeCliq!], type: .active)
                allCliqs.append(myActiveSectionCliq!)
            }
            
        }
        allCliqs.sort { (s1, s2) -> Bool in
            return s1.designatedIndex < s2.designatedIndex
        }
        
        self.adapter.reloadData(completion: nil)
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
        
        view.addSubview(collectionView)
        
        
        view.addSubview(floaty)
        adapter.collectionViewDelegate = self
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
    }
    
    
    func finishRegistrations(){
        NotificationCenter.set(observer: self, selector: #selector(updateNearby), name: .cliqEntered)
        NotificationCenter.set(observer: self, selector: #selector(updateData), name: .myCliqsUpdated)
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
        
        return allCliqs as [ListDiffable]
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
        
        let cliqsction = self.allCliqs[indexPath.section]
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

