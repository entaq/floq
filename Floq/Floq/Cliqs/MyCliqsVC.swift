//
//  MyCliqsVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 02/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import IGListKit


class MyCliqsVC: UIViewController {
    
    private let refresh = UIRefreshControl()
    
    private var photoEngine:CliqEngine{
        return (UIApplication.shared.delegate as! AppDelegate).mainEngine
    }
    
    lazy var adapter:ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 2)
    }()
    
    lazy var collectionView:UICollectionView = {
        let col = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        col.showsVerticalScrollIndicator = false
        return col
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupRefresh(){
        refresh.tintColor = .seafoamBlue
        refresh.attributedTitle = NSAttributedString(string: "Loading Cliqs....", attributes: [NSAttributedString.Key.foregroundColor : UIColor.seafoamBlue])
        refresh.addTarget(self, action: #selector(reload), for: .valueChanged)
        collectionView.refreshControl = refresh
        
    }
    
    @objc func reload(){
    
        photoEngine.queryForMyCliqs()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
          navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        let floaty = Floaty()
        floaty.buttonColor = .clear
        floaty.buttonImage = .icon_app_rounded
        floaty.fabDelegate = self
        
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        collectionView.backgroundColor = UIColor.globalbackground
        view.addSubview(collectionView)
        
        let barbutt = UIBarButtonItem(image: .icon_menu, style: .plain, target: self, action: #selector(accountMenuTapped))
        navigationItem.rightBarButtonItem = barbutt
        view.addSubview(floaty)
        finishRegistrations()
    }
    
    
    @objc func accountMenuTapped(){
        let storyboard = UIStoryboard.main
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
        adapter.scrollViewDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "My Cliqs"
        App.setDomain(.My_Cliqs)
    }
    
    func finishRegistrations(){
        NotificationCenter.set(observer: self, selector: #selector(updateData), name: .myCliqsUpdated)
    }
    
    func removeRegistrations(){
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateData(){
        adapter.reloadData(completion: nil)
        refresh.endRefreshing()
    }
    
    deinit {
        removeRegistrations()
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

        self.navigationController?.pushViewController(PhotosVC(cliq: cliq, id:cliq.id), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offset > contentHeight - scrollView.frame.height + 100{
           photoEngine.queryForMyCliqs()
        }
    }
}


extension MyCliqsVC:FloatyDelegate{
    
    func emptyFloatySelected(_ floaty: Floaty) {
        let vc = AddCliqVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}


