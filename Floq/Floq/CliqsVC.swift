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

final class CliqsVC : UIViewController, ListAdapterDataSource, UICollectionViewDelegate {
    var storageRef: StorageReference!
    let db = Firestore.firestore()
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 2)
    }()
    
    var data: [PhotoItem] = []
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = Storage.storage().reference()

        self.title = "Floq"

        view.addSubview(collectionView)

        let floaty = Floaty()

        floaty.addItem("Create a Cliq", icon: UIImage(named: "AppIcon")!, handler: { item in
            self.navigationController?.pushViewController(CreateCliqVC(), animated: true)
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
        adapter.collectionViewDelegate = self
        adapter.collectionView = collectionView
        adapter.dataSource = self
        queryPhotos()
        watchForPhotos()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func queryPhotos() {
        data = []
        db.collection("floq").order(by: "timestamp", descending: true).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        guard let cliqName = document["cliqName"] as? String else { continue }

                        let photoItem = PhotoItem(photoID: document.documentID, user: cliqName)
                        if !self.data.contains(photoItem) {
                            self.data.append(photoItem)
                        }
                        print("\(document.documentID) => \(document.data())")
                    }
                    self.adapter.reloadData(completion: nil)
                }
        }
    }
    
    func watchForPhotos() {
        // Do any additional setup after loading the view.
        db.collection("floq")
            .addSnapshotListener { documentSnapshot, error in
                guard let snapshot = documentSnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        guard let cliqName = diff.document["cliqName"] as? String else { return }

                        let photoItem = PhotoItem(photoID: diff.document.documentID, user: cliqName)
                        if !self.data.contains(photoItem) {
                            self.data.insert(photoItem, at: 0)
                            print("photo added: \(diff.document.data())")
                            self.adapter.reloadData(completion: nil)
                        }
                    }
                }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = self.data[indexPath.section]
        let documentID = photo.photoID
        let cliqName = photo.user
        self.navigationController?.pushViewController(PhotosVC(cliqDocumentID: documentID, cliqName: cliqName), animated: true)
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

    
   
}
