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
import Floaty


final class PhotosVC: UIViewController {
    
    var data: [GridPhotoItem] = []
    private var cliq:FLCliqItem!
    var photoEngine:PhotoEngine = PhotoEngine()
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 2)
    }()
    
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var userlistbutt:AvatarImageView!
    
    
    init(cliq:FLCliqItem){
        self.cliq = cliq
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .globalbackground
        
        navigationItem.hidesBackButton = false
          navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        view.addSubview(collectionView)
        
        
        let floaty = Floaty()
        floaty.buttonColor = .seafoamBlue
        floaty.plusColor = .white
        floaty.fabDelegate = self
        view.addSubview(floaty)
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        photoEngine.watchForPhotos(cliqDocumentID: cliq.id) { (photos, errm) in
            if let items = photos {
                
                self.data = items
                self.adapter.reloadData(completion: nil)
                
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = cliq.name
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        userlistbutt = AvatarImageView(frame:CGRect(origin: .zero, size: CGSize(width: 25, height: 25)))
        userlistbutt.setAvatar(uid: cliq.creatorUid)
        let uiview = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        let tp = UITapGestureRecognizer(target: self, action: #selector(userlistTapped))
        tp.numberOfTapsRequired = 1
        uiview.addGestureRecognizer(tp)
        uiview.addSubview(userlistbutt)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uiview)
        
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
                
                asset.fetchOriginalImage(options: nil, completeBlock: { (data, info) in
                    let filePath = "\(Int(Date.timeIntervalSinceReferenceDate * 1000))"
                    // [START uploadimage]
                    
                    
                    
                    let newMetadata = StorageMetadata()
                    var userEmail = "unknown"
                    var userName = "unknown"
                    if let realEmail = Auth.auth().currentUser?.email, let realName = Auth.auth().currentUser?.displayName {
                        userEmail = realEmail
                        userName = realName
                    }
                    newMetadata.customMetadata = [
                        Fields.fileID.rawValue : filePath,
                        Fields.userEmail.rawValue: userEmail,
                        Fields.username.rawValue : userName,
                        Fields.userUID.rawValue: Auth.auth().currentUser!.uid
                    ]
                    
                    self.photoEngine.storeImage(filePath: filePath, data: data!.jpegData(compressionQuality: 1)!, id: self.cliq.id, newMetadata: newMetadata, onFinish: { (suc, err) in
                        if let err = err{
                            self.present(UIAlertController.createDefaultAlert("OOPS", err,.alert, "OK",.default, nil), animated: true, completion: nil)
                        }else{
                            activityIndicator.removeFromSuperview()
                            self.present(UIAlertController.createDefaultAlert("SUCCESS", "Photo succesfully added to cliq",.alert, "OK",.default, nil), animated: true, completion: nil)
                        }
                    })
                    // [END uploadimage]
                })
                
            }
        }
        
        self.present(pickerController, animated: true) {}
        
    }
}


extension PhotosVC:ListAdapterDataSource{
    // MARK: ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        
        return data as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let gridSection = GridPhotoSection()
        gridSection.delegate = self
        return gridSection
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
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
}



extension PhotosVC:GridPhotoSectionDelegate{
    
    func didFinishSelecting(_ photo: PhotoItem, at index: Int) {
        let actualIndex = photoEngine.getTrueIndex(of: photo)
        let fullscreen = PhotoFullScreenVC(allphotos: photoEngine.allPhotos, selected: actualIndex,name:cliq.name)
        navigationController?.pushViewController(fullscreen, animated: true)
    }
}


extension PhotosVC:FloatyDelegate{
    
    func emptyFloatySelected(_ floaty: Floaty) {
        selectPhoto()
    }
}
