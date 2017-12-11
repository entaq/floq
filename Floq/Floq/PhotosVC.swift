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
import Firebase
import Floaty

final class PhotosVC: UIViewController, ListAdapterDataSource {
    var storageRef: StorageReference!
    let db = Firestore.firestore()

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 2)
    }()

    var data: [String] = []
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = Storage.storage().reference()
        
        view.addSubview(collectionView)
        
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
        queryPhotos()
        watchForPhotos()
    }
    
    func queryPhotos(){
        data = []
        db.collection("floq").document("defaultTest")
            .collection("photos").order(by: "timestamp", descending: true).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if !self.data.contains(document.documentID) {
                            self.data.append(document.documentID)
                        }
                        print("\(document.documentID) => \(document.data())")
                    }
                    self.adapter.reloadData(completion: nil)
                }
        }
    }

    func watchForPhotos() {
        // Do any additional setup after loading the view.
        db.collection("floq").document("defaultTest").collection("photos")
            .addSnapshotListener { documentSnapshot, error in
                guard let snapshot = documentSnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        if !self.data.contains(diff.document.documentID) {
                            self.data.insert(diff.document.documentID, at: 0)
                            print("photo added: \(diff.document.data())")
                            self.adapter.reloadData(completion: nil)
                        }
                    }
                }
        }
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
        return PhotoSection()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }

    @objc func selectPhoto() {
        let pickerController = DKImagePickerController()
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            
            for asset in assets {
                
                asset.fetchImageDataForAsset(false, completeBlock: { (data, info) in
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
                    
                    self.storageRef.child(filePath)
                        .putData(data!, metadata: newMetadata, completion: { (metadata, error) in
                            if let error = error {
                                print("Error uploading: \(error)")
                                return
                            }
                            var docData: [String: Any] = [
                                "timestamp" : FieldValue.serverTimestamp()
                            ]
                            docData.merge(newMetadata.customMetadata!, uniquingKeysWith: { (_, new) in new })
                            print(docData, filePath)

                            self.db.collection("floq").document("defaultTest")
                                .collection("photos").document(filePath)
                                .setData(docData) { err in
                                    if let err = err {
                                        print("Error writing document: \(err)")
                                    } else {
                                        print("Document successfully written!")
                                    }
                            }
                    })
                    
                    // [END uploadimage]
                })
                
            }
        }
        
        self.present(pickerController, animated: true) {}
        
    }
}
