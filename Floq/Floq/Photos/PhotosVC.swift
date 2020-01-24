/**
 Copyright (c) 2016-present, Facebook, Inc. All rights reserved.
 
 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
import IGListKit
import DKImagePickerController
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth



final class PhotosVC: UIViewController {
    
    var isMyPhotos = false
    var data: [GridPhotoItem] = []
    var photosToDelete:Set<String> = []
    private var floaty:Floaty!
    private var cliq:FLCliqItem?
    private var cliqID:String!
    var photoEngine:PhotosEngine!
    private var canShowEmpty = false
    private var isSelecting:Bool = false
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 2)
    }()
    
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var userlistbutt:AvatarImageView!
    
    
    init(cliq:FLCliqItem? , id:String){
        self.cliq = cliq
        self.cliqID = id
        photoEngine = PhotosEngine(cliq: id)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.showsVerticalScrollIndicator = false
        subscribeTo(subscription: .invalidatePhotos, selector: #selector(invalidatePhoto(_:)))
        collectionView.backgroundColor = .globalbackground
        floaty = Floaty()
        floaty.fabDelegate = self
        if isMyPhotos{
            floaty.buttonImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            floaty.buttonImage = UIImage(named: "trashx")
            floaty.buttonColor = .deepRose
            floaty.isHidden = true
        }else{
            floaty.buttonColor = .seafoamBlue
            floaty.plusColor = .white
        }
        
        if cliq == nil{
            DataService.main.getCliq(id: cliqID) { (cliq, err) in
                if let cliq = cliq{
                    self.cliq = cliq
                    self.title = cliq.name
                    self.userlistbutt.setAvatar(uid: cliq.creatorUid)
                    if cliq.isActive && cliq.isMember(){UserDefaults.setLatest(cliq.id)}
                }
            }
        }
        navigationItem.hidesBackButton = false
          navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        view.addSubview(collectionView)
        
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        view.addSubview(floaty)
        photoEngine.watchForPhotos(cliqDocumentID:cliqID, for:isMyPhotos ? UserDefaults.uid : nil) { (success, errm) in
            if success{
                self.canShowEmpty = true
                self.adapter.reloadData(completion: nil)
                
            }
        }
        
    }
    
    @objc func invalidatePhoto(_ notification:Notification){
        let id = notification.userInfo?[.info] as? String
        photoEngine.generateGridItems(id:id)
        canShowEmpty = true
        adapter.reloadData(completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        App.setDomain(.Photos)
        self.title = cliq?.name ?? ""
        if let cliq = self.cliq{
            if cliq.isActive && cliq.isMember(){UserDefaults.setLatest(cliq.id)}
        }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        adapter.reloadData(completion: nil)
    }
    
    
    func setupViewForMyphotos(){
        let barbutton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectPhotos(_:)))
        barbutton.setTitleTextAttributes([.font:UIFont.systemFont(ofSize: 18, weight: .light), .foregroundColor:UIColor(red: 53/255, green: 125/255, blue: 237/255, alpha: 1)], for: .normal)
        navigationItem.rightBarButtonItem = barbutton
    }
    
    @objc func selectPhotos(_ sender:UIBarButtonItem){
        
        if isSelecting{
            sender.title = "Select"
            floaty.isHidden = true
            isSelecting = !isSelecting
            Subscription.main.post(suscription: .clearSelection, object: nil)
            floaty.buttonColor = .seafoamBlue
            floaty.plusColor = .white
            
        }else{
            sender.title = "Done"
            isSelecting = !isSelecting
            Subscription.main.post(suscription: .cellShakeAnim, object: nil)
            floaty.isHidden = false
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        if isMyPhotos{
            setupViewForMyphotos()
        }else{
            userlistbutt = AvatarImageView(frame:CGRect(origin: .zero, size: CGSize(width: 25, height: 25)))
            userlistbutt.setAvatar(uid: cliq?.creatorUid ?? "placeholder")
            let uiview = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
            let tp = UITapGestureRecognizer(target: self, action: #selector(userlistTapped))
            tp.numberOfTapsRequired = 1
            uiview.addGestureRecognizer(tp)
            uiview.addSubview(userlistbutt)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uiview)
        }
        
    }
    

    @objc func userlistTapped(){
        let list = photoEngine.getAllPhotoMetadata()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        if let vc = storyboard.instantiateViewController(withIdentifier: String(describing: UserListVC.self)) as? UserListVC{
            vc.list = list
            vc.cliq = cliq
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func selectPhoto() {
        
        let pickerController = DKImagePickerController()
        pickerController.assetType = .allPhotos
        let activityIndicator = LoaderView(frame: UIScreen.main.bounds)
        activityIndicator.label.text = "Uploading Photos, Please wait.."
        
        pickerController.didCancel = {
            
        }
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
           
            if assets.isEmpty{
                
                return
            }
            self.view.addSubview(activityIndicator)
            for asset in assets {
                //var error:NSError?
                
                asset.fetchOriginalImage(options: nil, completeBlock: { (image, info) in
                    let filePath = "\(Int(Date.timeIntervalSinceReferenceDate * 1000))"
                    // [START uploadimage]
                    let fixedImage = image?.fixImageOrientation()
                    let newMetadata = StorageMetadata()
                    let userName =  UserDefaults.username
                    
                    newMetadata.customMetadata = [
                        Fields.fileID.rawValue : filePath,
                        Fields.username.rawValue : userName,
                        Fields.userUID.rawValue: Auth.auth().currentUser!.uid,
                    ]
                    let fid = self.cliq?.id ?? self.cliqID
                    if let data = fixedImage?.dataFromJPEG(){
                        self.uploadImage(filePath: filePath, data: data, id: fid!, newMetadata: newMetadata,indicator: activityIndicator)
                    }
                    
                })
            }
        }
        
        self.present(pickerController, animated: true) {}
        
    }
    
    
    deinit {
        unsubscribe()
    }
    
    
    func uploadImage(filePath:String,data:Data,id:String,newMetadata:StorageMetadata, indicator:LoaderView){
        self.photoEngine.storeImage(filePath: filePath, data: data, id: id, newMetadata: newMetadata, onFinish: { (suc, err) in
            if let err = err{
                self.present(UIAlertController.createDefaultAlert("OOPS", err,.alert, "OK",.default, nil), animated: true, completion: nil)
            }else{
                indicator.removeFromSuperview()
                self.present(UIAlertController.createDefaultAlert("SUCCESS", "Photo succesfully added to cliq",.alert, "OK",.default, nil), animated: true, completion: nil)
            }
        })
    }
    
}


extension PhotosVC:ListAdapterDataSource, UICollectionViewDelegate{
    // MARK: ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        
        return photoEngine.photoGrids as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let gridSection = GridPhotoSection()
        gridSection.delegate = self
        return gridSection
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        if canShowEmpty{
            let uiview = UIView(frame: view.frame)
            let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: view.frame.height)))
            label.numberOfLines = 10
            label.textAlignment = .center
            label.textColor = UIColor.black
            label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            label.text = "Oops, this cliq is empty, try adding some photos"
            label.center = uiview.center
            uiview.addSubview(label)
            return uiview
        }
        //let loaderView = PhotoEmptyView(frame: view.frame)
        return nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offset > contentHeight - scrollView.frame.height + 100{
            photoEngine.watchForPhotos(cliqDocumentID:cliqID) { (success, errm) in
                if success{
                    self.canShowEmpty = true
                    self.adapter.performUpdates(animated: true, completion: nil)
                    
                }
            }
        }
    }
}



extension PhotosVC:GridPhotoSectionDelegate{
    
    func didFinishSelecting(_ photo: PhotoItem, at index: Int, for cell:UICollectionViewCell?) {
        if isMyPhotos && isSelecting{
            if let cell = cell as? PhotoCell{
                cell.setSeleted()
                if cell.itemSelected{
                    photosToDelete.insert(photo.id)
                }else{
                    photosToDelete.remove(photo.id)
                }
            }
        }else{
            let actualIndex = photoEngine.getTrueIndex(of: photo)
            guard let cliq = self.cliq else {return}
            let fullscreen = PhotoFullScreenVC(engine: photoEngine, selected: actualIndex,cliq:cliq,cliqID: cliqID)
            navigationController?.pushViewController(fullscreen, animated: true)
        }
    }
}


extension PhotosVC:FloatyDelegate{
    
    func emptyFloatySelected(_ floaty: Floaty) {
        if isMyPhotos && isSelecting{
            if !photosToDelete.isEmpty{
                let loader = LoaderView(frame: UIScreen.main.bounds)
                
                let photoString = photosToDelete.count == 1 ? "Photo" : "Photos"
                let alert = UIAlertController(title: "Delete \(photoString)", message: "Are tou sure you want to delete selected \(photoString.lowercased()) from this cliq?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    self.view.addSubview(loader)
                    self.photoEngine.deletePhotos(ids: self.photosToDelete) { [weak self] success in
                        guard let self = self else {return}
                        let sender = self.navigationItem.rightBarButtonItem ?? UIBarButtonItem()
                        loader.removeFromSuperview()
                        sender.title = "Select"
                        floaty.isHidden = true
                        self.isSelecting = !self.isSelecting
                        Subscription.main.post(suscription: .clearSelection, object: nil)
                        floaty.buttonColor = .seafoamBlue
                        floaty.plusColor = .white
                        if success{
                            SnackBar.makeSncakMessage(text:"\(photoString) deleted successfully")
                            self.photosToDelete.removeAll()
                           
                        }else{
                            SnackBar.makeSncakMessage(text: "Failed to delete \(photoString)", color: .deepRose)
                        }
                    }
                }))
                
                present(alert, animated: true, completion: nil)
                
            }
            return
        }
        if let cliq = self.cliq{
            if cliq.isMember(){
                selectPhoto()
            }else{
                if cliq.canFollow{
                    let alert = UIAlertController.createDefaultAlert(.info,.not_aCliqMember ,.alert, .cancel,.cancel, nil)
                    let join = UIAlertAction(title: "Join", style: .default) { (ac) in
                        DataService.main.joinCliq(cliq: self.cliq!)
                        self.cliq!.addMember()
                        self.selectPhoto()
                    }
                    
                    alert.addAction(join)
                    present(alert, animated: true, completion: nil)
                }else{
                    let alert = UIAlertController.createDefaultAlert(.info,.maxed_out_cliq ,.alert, .ok,.cancel, nil)
                    present(alert, animated: true, completion: nil)
                }
            }
        }
        
    }
}
