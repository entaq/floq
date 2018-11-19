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


final class PhotosVC: UIViewController, ListAdapterDataSource {
    
    private var storageRef:StorageReference{
        return Storage.storage().reference()
    }
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 2)
    }()
    
    var data: [GridPhotoItem] = []
    
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var cliqDocumentID: String
    var cliqName: String?
    var photoEngine:PhotoEngine = PhotoEngine()
    init(cliqDocumentID:String, cliqName:String?){
        self.cliqDocumentID = cliqDocumentID
        self.cliqName = cliqName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor.globalbackground()
        
        navigationItem.hidesBackButton = false
        view.addSubview(collectionView)
        self.title = cliqName
        
        let floaty = Floaty()
        
        floaty.addItem("Add photo", icon: UIImage(named: "AppIcon")!, handler: { item in
            self.selectPhoto()
        })
        floaty.addItem("Logout", icon: UIImage(named: "logout")!, handler: { item in
            do {
                try Auth.auth().signOut()
                self.dismiss(animated: true, completion: nil)
            } catch {
                print("error trying to logout")
            }
        })
        
        
        view.addSubview(floaty)
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        photoEngine.watchForPhotos(cliqDocumentID: cliqDocumentID) { (photos, errm) in
            if let items = photos {
                
                self.data = items
                self.adapter.reloadData(completion: nil)
                
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
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
    
    
    
    
    
    @objc func selectPhoto() {
        let pickerController = DKImagePickerController()
        let activityIndicator = LoaderView(frame: UIScreen.main.bounds)
        activityIndicator.label.text = "Uploading Photos, Please wait.."
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            self.view.addSubview(activityIndicator)
            for asset in assets {
                
                asset.fetchOriginalImage(options: nil, completeBlock: { (data, info) in
                    let filePath = "\(Int(Date.timeIntervalSinceReferenceDate * 1000))"
                    // [START uploadimage]
                    
                    
                    // Create file metadata to update
                    let newMetadata = StorageMetadata()
                    var userEmail = "unknown"
                    var userName = "unknown"
                    if let realEmail = Auth.auth().currentUser?.email, let realName = Auth.auth().currentUser?.displayName {
                        userEmail = realEmail
                        userName = realName
                    }
                    newMetadata.customMetadata = [
                        "fileID" : filePath,
                        "userEmail": userEmail,
                        "userName" : userName,
                        "userID": Auth.auth().currentUser!.uid
                    ]
                    
                    self.photoEngine.storeImage(filePath: filePath, data: UIImageJPEGRepresentation(data!, 1)!, id: self.cliqDocumentID, newMetadata: newMetadata, onFinish: { (suc, err) in
                        if let err = err{
                            self.present(createDefaultAlert("OOPS", err,.alert, "OK",.default, nil), animated: true, completion: nil)
                        }else{
                            activityIndicator.removeFromSuperview()
                            self.present(createDefaultAlert("SUCCESS", "Photo succesfully added to cliq",.alert, "OK",.default, nil), animated: true, completion: nil)
                        }
                    })
                    // [END uploadimage]
                })
                
            }
        }
        
        self.present(pickerController, animated: true) {}
        
    }
}



extension PhotosVC:GridPhotoSectionDelegate{
    
    func didFinishSelecting(_ photo: PhotoItem, at index: Int) {
        let actualIndex = photoEngine.getTrueIndex(of: photo)
        let fullscreen = PhotoFullScreenVC(allphotos: photoEngine.allPhotos, selected: actualIndex)
        navigationController?.pushViewController(fullscreen, animated: true)
    }
}

