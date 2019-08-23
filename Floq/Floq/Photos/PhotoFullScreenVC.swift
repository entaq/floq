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
    
    private var _AREA_INSET:CGFloat = 0
    
    lazy var flag:UIImageView = {
        let view = UIImageView(image: .icon_flag)
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private var initialFrame:CGRect!
    private var avatatFrame:CGRect!
    private var commentShowing = false
    private var holderIndex = 0
    private lazy var commentIcon:CommentButton = { [unowned self] by in
        let button = CommentButton(frame: .zero)
        //button.setTitle("Comment", for: .normal)
        button.addTarget(self, action: #selector(commentTapped(_:)), for: .touchUpInside)
        return button
    }(())

    var engine:PhotosEngine!
    var likelabel:UILabel!
    var likebar:UIView  = UIView(frame: .zero)
    var selectedIndex:Int = 0
    var imgv:UIImageView!
    private var photoFileID:String?
    private var cliq:FLCliqItem?
    
    var userUid:String?
    var username:String?
    var total:Int!
    var currentPhotoID:String?
    var isSelected = false
    var inset:CGFloat = 30
    private var cliqID:String
    init(engine:PhotosEngine, selected index:Int, cliq:FLCliqItem,cliqID:String){
        self.engine = engine
        self.selectedIndex = index
        self.holderIndex = index
        self.cliq = cliq
        self.cliqID = cliqID
        super.init(nibName: nil, bundle: nil)
        
        runConfig()
        
    }
    
    func runConfig(){
        let handle = UIScreen.main.screenType()
        
        switch handle {
        case .xmax_xr:
            inset = 60
            _AREA_INSET = 20
            return
        case .xs_x:
            inset = 60
            _AREA_INSET = 20
            return
        case .pluses:
            inset = 30
            return
        case .eight_lower:
            inset = 30
        default:
            inset = 30
            return
        }
    }
    
    private lazy var commentContainer:UIView = {
        let container = UIView(frame: .zero)
        container.backgroundColor = .white
        container.clipsToBounds = true
        return container
    }()

    
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
    
    
    //public private (set) lazy var a:Stream = {[unowned self] by in return .init()}(())
    
    private lazy var hideCommentIcon:UIImageView = {[unowned self] by in
        let img =  UIImageView.init(frame:.zero)
        img.contentMode = .scaleAspectFill
        img.isUserInteractionEnabled = true
        img.image = #imageLiteral(resourceName: "group")
        let tap = UITapGestureRecognizer(target: self, action: #selector(collapseComment(_:)))
        tap.numberOfTapsRequired = 1
        img.addGestureRecognizer(tap)
        img.isHidden = true
        return img
    }(())
    
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
        view.addSubview(commentContainer)
        view.addSubview(collectionView)
        view.addSubview(hideCommentIcon)
        createLikeBar()
        collectionView.isPagingEnabled = true
        setup()
        addSwipeUpGesture()
        subscribeTo(subscription: .cmt_photo_notify, selector: #selector(listenForCommentAddedNotification(_:)))
    }
    
    func addSwipeUpGesture(){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp(_:)))
        swipe.direction = .up
        collectionView.addGestureRecognizer(swipe)
    }
    
    @objc func swipedUp(_ recognizer:UISwipeGestureRecognizer){
        if commentShowing{
           let newframe = CGRect(x: 0, y: -60, width: view.bounds.width, height: 0)
            let newFrameTable = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.frame.height)
            avatarImageview.isHidden = true
            UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseInOut, animations: {
                self.collectionView.frame = newframe
                self.commentContainer.frame = newFrameTable
            }, completion: nil)
        }
    }
    
    @objc func reloadPhotos(){
         adapter.reloadData(completion: nil)
    }
    
    
    func reload(id:String){
        engine.generateGridItems(photoId:id)
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
                
               let sheet = UIActivityViewController(activityItems: [image, " -Shared from Floq App",], applicationActivities: [])
                present(sheet, animated: true) {}
                
            }
        }
        
    }
    
    @objc func collapseComment(_ recognizer:UITapGestureRecognizer){
        resetViews()
    }
    
    @objc func commentTapped(_ sender: UIButton){
        //showCommentAnimation()
        if currentPhotoID != nil && commentIcon.broadcast{
           CMTSubscription().endHightlightFor(currentPhotoID!)
        }
        
        guard let id = currentPhotoID else {return}
        let vc = CommentsVC(id: id, (self._AREA_INSET > 1) ? true : false,cliqID: cliqID)
        navigationController?.pushViewController(vc, animated: true)
        selectedIndex = Int.largest
    }
    
    func resetViews(){
        commentShowing = false
        if avatarImageview.isHidden { avatarImageview.isHidden = false }
        
        avatatFrame = CGRect(x: self.view.center.x - 30, y: inset, width: 60, height: 60)
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: .curveEaseInOut, animations: {
            self.collectionView.frame = self.initialFrame
            self.avatarImageview.frame = self.avatatFrame
            self.avatarImageview.layer.cornerRadius = 30
            self.hideCommentIcon.isHidden = true
            self.commentContainer.frame = CGRect(x: 0, y: (UIScreen.height * 0.55) - 60, width: self.view.bounds.width, height: (UIScreen.height * 0.45) - self._AREA_INSET)
            self.likebar.isHidden = false
        }, completion: {_ in if let child = self.children.first(where: { v -> Bool in return type(of: v) == CommentsVC.self}){child.removeFrom()
        }})
        reloadPhotos()
    }
    
    func showCommentAnimation(){
        commentShowing = true
        let newf = CGRect(x: 0, y: -60, width: view.bounds.width, height: UIScreen.height * 0.55)
        let x = view.frame.width - 100
        //let y =  (self.collectionView.frame.size.height - (UIScreen.hei)) - 10
        avatatFrame = CGRect(x:x, y:(newf.maxY + 20 + _AREA_INSET) , width: 80, height: 80)
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: .curveEaseInOut, animations: {
            self.collectionView.frame = newf//.size.height -= (UIScreen.main.bounds.height * 0.4)
            self.avatarImageview.layer.cornerRadius = 40
            self.avatarImageview.frame = self.avatatFrame
            self.hideCommentIcon.isHidden = false
            self.likebar.isHidden = true
            //self.avatarImageview.transform.scaledBy(x: 1.5, y: 1.5)
        }, completion: { _ in
            let vc = CommentsVC(id:self.currentPhotoID!,(self._AREA_INSET > 1) ? true : false,cliqID: self.cliqID)
            vc.view.frame.size = self.commentContainer.frame.size
            self.add(vc, to: self.commentContainer)
        })
    }
    
    
//    func shareOnFaceBook(){
//        guard let cell = collectionView.visibleCells.first as? FullScreenCell,
//            let image = cell.imageView.image else {return}
//        let fbshare = SocialShare(platform: .facebook)
//        fbshare.share(image: image)
//        
//        
//    }
    
    
    func setup(){
        initialFrame = CGRect(x: 0, y: -60, width: view.bounds.width, height: UIScreen.height)
        avatatFrame = CGRect(x: self.view.center.x - 30, y: inset, width: 60, height: 60)
        let cy = (UIScreen.height * 0.55) - 60
        commentContainer.frame = CGRect(x: 0, y: cy, width: view.bounds.width, height: (UIScreen.height * 0.45) - _AREA_INSET)
        collectionView.frame = initialFrame
        let y = UIScreen.height * 0.50 - 60
        hideCommentIcon.frame = CGRect(x: 12, y: y, width: 30, height: 30)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    func setAvatarView(){
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(tappedAvatar(_:)))
        tapImage.numberOfTapsRequired = 1
        avatarImageview.isUserInteractionEnabled = true
        avatarImageview.addGestureRecognizer(tapImage)
        avatarImageview.frame = avatatFrame
        avatarImageview.backgroundColor = UIColor.white
        avatarImageview.layer.cornerRadius = avatarImageview.frame.width / 2
        avatarImageview.layer.borderWidth = 2
        avatarImageview.image = .placeholder
        avatarImageview.layer.borderColor = UIColor.white.cgColor
        self.navigationController?.view.addSubview(avatarImageview)

        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setAvatarView()
        collectionView.backgroundColor = .globalbackground
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        adapter.reloadData(completion: nil)
        if selectedIndex < engine.allPhotos.count{
            moveToNext()
        }else{
            selectedIndex = holderIndex
        }
        
        subscribeTo(subscription: .reloadPhotos, selector: #selector(reloadPhotos))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        avatarImageview.removeFromSuperview()
        unsubscribe()
    }
    
    
    
    
    func moveToNext(_ index:Int? = nil){

        let index = index ?? selectedIndex
        guard (index < engine.allPhotos.endIndex) else{return}
        let obj = engine.allPhotos[index]
        adapter.collectionViewDelegate = self
        adapter.scroll(to: obj, supplementaryKinds: nil, scrollDirection: .horizontal, scrollPosition: .centeredHorizontally, animated: false)
    }
    
    deinit {
        unsubscribe()
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
        likebar.addSubview(flag)
        likebar.addSubview(commentIcon)
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
            //imgv.rightAnchor.constraint(equalTo: likebar.rightAnchor, constant:-20)
            imgv.centerXAnchor.constraint(equalTo: likebar.centerXAnchor, constant: 0)
        ])
        likelabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            likelabel.rightAnchor.constraint(equalTo: imgv.leftAnchor, constant: -16),
            likelabel.centerYAnchor.constraint(equalTo: likebar.centerYAnchor),
            likelabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        flag.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            flag.leadingAnchor.constraint(equalTo: likebar.leadingAnchor, constant: 20),
            flag.heightAnchor.constraint(equalToConstant: 30),
            flag.widthAnchor.constraint(equalToConstant: 20),
            flag.centerYAnchor.constraint(equalTo: likebar.centerYAnchor),
            
        ])
        commentIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commentIcon.trailingAnchor.constraint(equalTo: likebar.trailingAnchor, constant: -12),
            commentIcon.centerYAnchor.constraint(equalTo: likebar.centerYAnchor, constant: 0),
            commentIcon.widthAnchor.constraint(equalToConstant: 40),
            commentIcon.heightAnchor.constraint(equalToConstant: 30)
        ])
        likelabel.textColor = .white
        likelabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        likelabel.backgroundColor = .clear
        
        imgv.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(AnimateImage(_:)))
        tap.numberOfTapsRequired = 1
        imgv.addGestureRecognizer(tap)
        flag.isUserInteractionEnabled = true
        let ftap = UITapGestureRecognizer(target: self, action: #selector(flagPressed(_:)))
        ftap.numberOfTapsRequired = 1
        flag.addGestureRecognizer(ftap)
        
    }
    
    @objc func flagPressed(_ recognizer: UITapGestureRecognizer){
       let alert = UIAlertController.createDefaultAlert("Flag this image as abusive or inappropriate?", "By flagging this image it will be removed from the 'cliq' and the administrators of the app will review the content and permanently remove any images and users associated with it if found to be agains the End User Agreement.",.alert, "Cancel",.cancel, nil)
        let flag = UIAlertAction(title: "Report", style: .destructive) { _ in
            let loader = LoaderView(frame: UIScreen.main.bounds)
            self.flagAPhoto(view: loader)
        }
        
        alert.addAction(flag)
        present(alert, animated: true, completion: nil)
    }
    
    func flagAPhoto(view:LoaderView){
        guard let id = currentPhotoID, let cliq = self.cliq else {return}
        let cliqID = (cliq.fileID == photoFileID!) ? cliq.id : nil
        engine.flagPhoto(photoID: id, cliqID: cliqID) { (success, errM) in
            view.removeFromSuperview()
            if (success){
                Subscription.main.post(suscription: .photoFlagged, object:self.photoFileID ?? "" )
                let alert = UIAlertController.createDefaultAlert("Success", "Content was succesfully reported",.alert, "OK",.default, nil)
                self.present(alert, animated: true, completion: nil)
                self.reload(id: id)
            }
        }
    }
    
    func resetPhotos(){
        if engine.allPhotos.isEmpty{
            navigationController?.popViewController(animated: true)
            return
        }
        if selectedIndex < engine.allPhotos.endIndex{
            moveToNext()
        }else{
            moveToNext(engine.allPhotos.endIndex - 1)
        }
    }
    
    
    
}


extension PhotoFullScreenVC:FullScreenScetionDelegate{
    
    
    func photoWasSelected() {
        if isSelected{
            
            UIView.animate(withDuration: 0.5) {
                self.navigationController?.navigationBar.alpha = 1
                if #available(iOS 13, *){
                    if let window = (UIApplication.shared.delegate as? AppDelegate)?.window{
                        //window.windowScene?.statusBarManager
                    }
                }else{
                    let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
                    statusBar?.alpha = 1
                }
                
                self.avatarImageview.alpha = 1
                self.likebar.alpha = 1
                self.collectionView.backgroundColor = .globalbackground
                self.isSelected = false
            }
        }else{
            UIView.animate(withDuration: 0.5) {
                self.navigationController?.navigationBar.alpha = 0
                
                if #available(iOS 13.0, *) {
                    if let window = (UIApplication.shared.delegate as? AppDelegate)?.window{
                         //window.windowScene?.statusBarManager
                    }
                   
                } else {
                    let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
                    statusBar?.alpha = 0
                }
            
                
                self.avatarImageview.alpha = 0
                self.likebar.alpha = 0
                self.collectionView.backgroundColor = .black
                self.isSelected = true
            }
        }
    }
    
    func willDisplayPhoto(with reference: StorageReference, for user: (String, String,Int,Bool), _ photoId: String, fileId:String) {
        currentPhotoID = photoId
        engine.getExtraLikes(id: photoId)
        photoFileID = fileId
        userUid = user.0
        avatarImageview.sd_setImage(with: reference, placeholderImage: UIImage.placeholder)
        username = user.1
        likelabel.text = "\(user.2)"
        imgv.isUserInteractionEnabled = !user.3
        imgv.image = user.3 ? .icon_like : .icon_unlike
        checkNotifiable(id: photoId)
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
            return item.id == currentPhotoID!
        }){
            if !photo.likers.contains(UserDefaults.uid){
                
                likelabel.text = "\(photo.likes + 1)"
                imgv.isUserInteractionEnabled = false
                guard let cliqID = cliq?.id else {return}
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
            return item.id == currentPhotoID!
        }){
            if !photo.likers.contains(UserDefaults.uid){
                
                likelabel.text = "\(photo.likes + 1)"
                imgv.isUserInteractionEnabled = false
                guard let cliqID = cliq?.id else {return}
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


// Mark : - CMTSUbscription

extension PhotoFullScreenVC{
    
    @objc func listenForCMTsubscription(_ notification:Notification){
        guard let id = notification.userInfo?[.info] as? String, let photoID = currentPhotoID else {return}
        if id == cliqID{
            let photo = CMTSubscription().fetchPhotoSub(id: photoID)
            if photo?.canBroadcast ?? false{
                commentIcon.broadcast = true
            }
        }
    }
    
    @objc func listenForCommentAddedNotification(_ notification:Notification){
        guard let id = notification.userInfo?[.info] as? String else {return}
        checkNotifiable(id: id)
    }
    
    func checkNotifiable(id:String){
        let notifier = CMTSubscription()
        if let notif = notifier.fetchPhotoSub(id:id){
            commentIcon.broadcast = notif.canBroadcast
        }else{
            commentIcon.broadcast = false
        }
    }
}



