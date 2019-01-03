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
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let butt = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        navigationItem.rightBarButtonItem = butt
        view.addSubview(collectionView)
        collectionView.isPagingEnabled = true
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
        collectionView.frame = view.bounds
        setAvatarView()
        collectionView.backgroundColor = .globalbackground
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        adapter.reloadData(completion: nil)
        let obj = allphotos[selectedIndex]
        adapter.scroll(to: obj, supplementaryKinds: nil, scrollDirection: .horizontal, scrollPosition: .centeredHorizontally, animated: false)
    }
    
    func setAvatarView(){
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(tappedAvatar(_:)))
        tapImage.numberOfTapsRequired = 1
        avatarImageview.isUserInteractionEnabled = true
        avatarImageview.addGestureRecognizer(tapImage)
        avatarImageview.frame =  CGRect(x: self.view.center.x - 35, y: 40, width: 60, height: 60)
        avatarImageview.backgroundColor = UIColor.white
        avatarImageview.layer.cornerRadius = 30
        avatarImageview.layer.borderWidth = 2
        avatarImageview.image = .placeholder
        avatarImageview.layer.borderColor = UIColor.white.cgColor
        self.navigationController?.view.addSubview(avatarImageview)


        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        let section = FullScreenPhotoSection()
        section.delegate = self
        return section
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {

        return nil
    }
    
}


extension PhotoFullScreenVC:FullScreenScetionDelegate{
    
    func willDisplayPhoto(with reference: StorageReference, for userid:String) {
        userUid = userid
        avatarImageview.sd_setImage(with: reference, placeholderImage: UIImage.placeholder)
    }
    
    @objc func tappedAvatar(_ tapGestureRecognizer:UITapGestureRecognizer){
        if let id  = userUid{
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            if let vc = storyboard.instantiateViewController(withIdentifier: String(describing: UserProfileVC.self)) as? UserProfileVC{
                vc.userID = id
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

