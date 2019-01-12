//
//  PhotoFullScreenVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 17/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit
import IGListKit
import FirebaseStorage

class PhotoFullScreenVC: UIViewController {

    var allphotos:[PhotoItem]!
    var selectedIndex:Int = 0
    var floqname:String
    var userUid:String?
    var username:String?
    var total:Int!
    var isSelected = false
    init(allphotos:[PhotoItem], selected index:Int, name:String){
        self.allphotos =  allphotos
        self.selectedIndex = index
        floqname = name
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
        total = allphotos.count
        
          navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let butt = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        navigationItem.rightBarButtonItem = butt
        view.addSubview(collectionView)
        collectionView.isPagingEnabled = true
    }
    
    
    
    func updateTitle(index:Int){
        title = "\(index + 1) / \(total!)"
    }
    
    @objc func share(){
        if let cell = collectionView.visibleCells.first as? FullScreenCell{
            if let image = cell.imageView.image{
                let sheet = UIAlertController.createDefaultAlert("Save Photo", "",.actionSheet, "cancel",.cancel, nil)
                let action = UIAlertAction(title: "Save", style: .default) { (ac) in
                    let album = CustomPhotoAlbum(album: self.floqname)
                    album.save(image:image)
                    self.present(UIAlertController.createDefaultAlert("INFO", "Photo succesfully saved 🎉🎉🎊",.alert, "Dismiss",.cancel, nil), animated:true, completion: nil)
                }
                sheet.addAction(action)
                present(sheet, animated: true, completion: nil)
            }else{
                //present(createDefaultAlert("INFO", "Photo succesfully saved 🎉🎉🎊",.alert, "Dismiss",.cancel, nil), animated:true, completion: nil)
            }
        }
        
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    func setAvatarView(){
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(tappedAvatar(_:)))
        tapImage.numberOfTapsRequired = 1
        avatarImageview.isUserInteractionEnabled = true
        avatarImageview.addGestureRecognizer(tapImage)
        avatarImageview.frame =  CGRect(x: self.view.center.x - 30, y: 30, width: 60, height: 60)
        avatarImageview.backgroundColor = UIColor.white
        avatarImageview.layer.cornerRadius = 30
        avatarImageview.layer.borderWidth = 2
        avatarImageview.image = .placeholder
        avatarImageview.layer.borderColor = UIColor.white.cgColor
        self.navigationController?.view.addSubview(avatarImageview)


        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.frame = CGRect(x: 0, y: -60, width: view.bounds.width, height: view.bounds.height + 60)
        setAvatarView()
        collectionView.backgroundColor = .globalbackground
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        adapter.reloadData(completion: nil)
        let obj = allphotos[selectedIndex]
        adapter.collectionViewDelegate = self
        adapter.scroll(to: obj, supplementaryKinds: nil, scrollDirection: .horizontal, scrollPosition: .centeredHorizontally, animated: false)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        avatarImageview.removeFromSuperview()
    }
}


extension PhotoFullScreenVC:ListAdapterDataSource,UICollectionViewDelegate{

    

    
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        
        return allphotos as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let section = FullScreenPhotoSection()
        section.delegate = self
        return section
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {

        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSelected{
            
            UIView.animate(withDuration: 0.5) {
                self.navigationController?.navigationBar.alpha = 1
                let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
                statusBar?.alpha = 1

                self.avatarImageview.alpha = 1
                self.collectionView.backgroundColor = .globalbackground
                self.isSelected = false
            }
        }else{
            UIView.animate(withDuration: 0.5) {
                self.navigationController?.navigationBar.alpha = 0
                let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
                statusBar?.alpha = 0
                self.avatarImageview.alpha = 0
                self.collectionView.backgroundColor = .black
                self.isSelected = true
            }
        }
        
    }
    
}


extension PhotoFullScreenVC:FullScreenScetionDelegate{
    
    func willDisplayPhoto(with reference: StorageReference, for user: (String,String)) {
        userUid = user.0
        avatarImageview.sd_setImage(with: reference, placeholderImage: UIImage.placeholder)
        username = user.1
    }
    
    func willDisplayIndex(_ index:Int){
        
    }
    
    
    
    @objc func tappedAvatar(_ tapGestureRecognizer:UITapGestureRecognizer){
        if let id  = userUid{
            
            let vc = ProfileImageVC(id: id, name:username ?? "Floq user")
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}

