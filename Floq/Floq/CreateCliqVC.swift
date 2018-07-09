//
//  CreatCliqVC.swift
//  Floq
//
//  Created by Arun Nagarajan on 7/8/18.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import Eureka
import Firebase

class CreateCliqVC : FormViewController {
    var storageRef: StorageReference!
    let db = Firestore.firestore()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = Storage.storage().reference()

        self.title = "Create a Cliq"
        
        form +++
            Section()
            <<< ImageRow("photo" ){
                $0.title = "Add Cover Photo"
            }
            <<< TextFloatLabelRow("name") {
                $0.title = "Give your Cliq a name"
            }
            +++ Section()
            +++ Section(footer: "Other nearby users can find this")
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Create"
                }
                .onCellSelection { [weak self] (cell, row) in
                    self?.createCliq()
        }

    }
    
    func createCliq() {
        
        let imageRow: ImageRow? = form.rowBy(tag: "photo")
        let imageValue = imageRow?.value
        
        let nameRow: TextFloatLabelRow? = form.rowBy(tag: "name")
        let nameValue = nameRow?.value

        guard let name : String = nameValue else {
            print("name is not a string")
            return
        }
        
        guard let image : UIImage = imageValue else {
            print("image is not an UIImage")
            return
        }
        
        let filePath = "\(name) - \(Int(Date.timeIntervalSinceReferenceDate * 1000))"
        
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
            "userID": Auth.auth().currentUser!.uid,
            "cliqName" : name
        ]
        
        var data = Data()
        data = UIImageJPEGRepresentation(image, 1.0)! 

        self.storageRef.child(filePath)
            .putData(data, metadata: newMetadata, completion: { (metadata, error) in
                if let error = error {
                    print("Error uploading: \(error)")
                    return
                }
                var docData: [String: Any] = [
                    "timestamp" : FieldValue.serverTimestamp()
                ]
                docData.merge(newMetadata.customMetadata!, uniquingKeysWith: { (_, new) in new })
                print(docData, filePath)

                self.db.collection("floq").document(filePath)
                    .setData(docData) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                        self.navigationController?.popViewController(animated: true)
                }
            })
    }
    
}

