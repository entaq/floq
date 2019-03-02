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

    var engine:PhotosEngine!
    var likelabel:UILabel!
    var likebar:UIView  = UIView(frame: .zero)
    var selectedIndex:Int = 0
    var imgv:UIImageView!
    var floqname:String
    var userUid:String?
    var username:String?
    var total:Int!
    var currentPhotoID:String?
    private var cliqID:String
    var isSelected = false
    init(engine:PhotosEngine, selected index:Int, name:String, id:String){
        self.engine = engine
        self.selectedIndex = index
        cliqID = id
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
        total = engine.allPhotos.count
        
          navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let butt = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        navigationItem.rightBarButtonItem = butt
        view.addSubview(collectionView)
        createLikeBar()
        collectionView.isPagingEnabled = true
        
    }
    
    @objc func reload(){
        adapter.reloadData(completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func updateTitle(index:Int){
        title = "\(index + 1) / \(total!)"
    }
    
    @objc func share(){
        if let cell = collectionView.visibleCells.first as? FullScreenCell{
            if let image = cell.imageView.image{
                
               let sheet = UIActivityViewController(activityItems: [" -Shared from Floq App",image], applicationActivities: [])
                present(sheet, animated: true) {
                    //
                }
                
//                let sheet = UIAlertController.createDefaultAlert("Save Photo", "",.actionSheet, "cancel",.cancel, nil)
//                let action = UIAlertAction(title: "Save", style: .default) { (ac) in
//                    let album = CustomPhotoAlbum(album: self.floqname)
//                    album.save(image: image, handler:{ (success, err) in
//                        if success{
//                            self.present(UIAlertController.createDefaultAlert("INFO", "Photo succesfully saved 🎉🎉🎊",.alert, "Dismiss",.cancel, nil), animated:true, completion: nil)
//                        }else{
//                            self.present(UIAlertController.createDefaultAlert("ERROR", "Photo could not be saved: ++\(err ?? "Unknown Error")",.alert, "Dismiss",.cancel, nil), animated:true, completion: nil)
//                        }
//                    })
//
//                }
//                let shareAction = UIAlertAction(title: "Share on Facebook", style: .default) { (ac) in
//                    self.shareOnFaceBook()
//                }
//                sheet.addAction(action)
//                sheet.addAction(shareAction)
//                present(sheet, animated: true, completion: nil)
//            }else{
//                //present(createDefaultAlert("INFO", "Photo succesfully saved 🎉🎉🎊",.alert, "Dismiss",.cancel, nil), animated:true, completion: nil)
//            }
            }
        }
        
    }
    
    
//    func shareOnFaceBook(){
//        guard let cell = collectionView.visibleCells.first as? FullScreenCell,
//            let image = cell.imageView.image else {return}
//        let fbshare = SocialShare(platform: .facebook)
//        fbshare.share(image: image)
//        
//        
//    }
    
    
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
        let obj = engine.allPhotos[selectedIndex]
        adapter.collectionViewDelegate = self
        adapter.scroll(to: obj, supplementaryKinds: nil, scrollDirection: .horizontal, scrollPosition: .centeredHorizontally, animated: false)
        NotificationCenter.set(observer: self, selector: #selector(reload), name: .modified)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        avatarImageview.removeFromSuperview()
    }
}


extension PhotoFullScreenVC:ListAdapterDataSource,UICollectionViewDelegate{

    

    
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        
        return engine.allPhotos as [ListDiffable]
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
        
        
    }
    
    func createLikeBar(){
        imgv = UIImageView(image: UIImage.icon_unlike)
        likelabel = UILabel(frame: .zero)
        view.addSubview(likebar)
        likebar.addSubview(imgv)
        likebar.addSubview(likelabel)
        likebar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            likebar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            likebar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            likebar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            likebar.heightAnchor.constraint(equalToConstant: 60)
        ])
        likebar.backgroundColor = .charcoal
        
        
        imgv.translatesAutoresizingMaskIntoConstraints = false
        imgv.clipsToBounds = true
        NSLayoutConstraint.activate([
            imgv.heightAnchor.constraint(equalToConstant: 30),
            imgv.widthAnchor.constraint(equalToConstant: 30),
            imgv.centerYAnchor.constraint(equalTo: likebar.centerYAnchor),
            imgv.rightAnchor.constraint(equalTo: likebar.rightAnchor, constant:-20)
        ])
        likelabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            likelabel.rightAnchor.constraint(equalTo: imgv.leftAnchor, constant: -16),
            likelabel.centerYAnchor.constraint(equalTo: likebar.centerYAnchor),
            likelabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        likelabel.textColor = .white
        likelabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        likelabel.backgroundColor = .clear
        
        imgv.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(AnimateImage(_:)))
        tap.numberOfTapsRequired = 1
        imgv.addGestureRecognizer(tap)
        
    }
    
}


extension PhotoFullScreenVC:FullScreenScetionDelegate{
    
    
    func photoWasSelected() {
        if isSelected{
            
            UIView.animate(withDuration: 0.5) {
                self.navigationController?.navigationBar.alpha = 1
                let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
                statusBar?.alpha = 1
                
                self.avatarImageview.alpha = 1
                self.likebar.alpha = 1
                self.collectionView.backgroundColor = .globalbackground
                self.isSelected = false
            }
        }else{
            UIView.animate(withDuration: 0.5) {
                self.navigationController?.navigationBar.alpha = 0
                let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
                statusBar?.alpha = 0
                self.avatarImageview.alpha = 0
                self.likebar.alpha = 0
                self.collectionView.backgroundColor = .black
                self.isSelected = true
            }
        }
    }
    
    func willDisplayPhoto(with reference: StorageReference, for user: (String, String,Int,Bool), _ photoId: String) {
        currentPhotoID = photoId
        engine.getExtraLikes(id: photoId)
        userUid = user.0
        avatarImageview.sd_setImage(with: reference, placeholderImage: UIImage.placeholder)
        username = user.1
        likelabel.text = "\(user.2)"
        imgv.isUserInteractionEnabled = !user.3
        imgv.image = user.3 ? .icon_like : .icon_unlike
    }
    
    
    func photoWasLiked(id:String?) {
        //guard let id = id else{return}
        //engine.likeAPhoto(cliqID: cliqID, id:id)
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: {
            self.imgv.transform = self.imgv.transform.scaledBy(x: 2, y: 2)
            self.imgv.image = .icon_like
        }) { (suc) in
            //
        }
        UIView.animate(withDuration: 0.6, delay: 1.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            self.imgv.transform = CGAffineTransform.identity
            
        }) { (b) in
            
        }
        if let photo = engine.allPhotos.first(where: { (item) -> Bool in
            return item.absoluteID == currentPhotoID!
        }){
            if !photo.likers.contains(UserDefaults.uid){
                
                likelabel.text = "\(photo.likes + 1)"
                imgv.isUserInteractionEnabled = false
                engine.likeAPhoto(cliqID: cliqID, id: currentPhotoID!)
            }
        }
        
    }
    
    
    
    @objc func AnimateImage(_ recognizer:UITapGestureRecognizer){
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: {
            self.imgv.transform = self.imgv.transform.scaledBy(x: 2, y: 2)
            
        }) { (suc) in
                //
        }
        UIView.animate(withDuration: 0.6, delay: 1.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            self.imgv.transform = CGAffineTransform.identity
            
        }) { (b) in
            
        }
        if let photo = engine.allPhotos.first(where: { (item) -> Bool in
            return item.absoluteID == currentPhotoID!
        }){
            if !photo.likers.contains(UserDefaults.uid){
                
                likelabel.text = "\(photo.likes + 1)"
                imgv.isUserInteractionEnabled = false
                engine.likeAPhoto(cliqID: cliqID, id: currentPhotoID!)
            }
        }
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

