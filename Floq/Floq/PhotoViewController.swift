//
//  PhotoViewController.swift
//  Floq
//
//  Created by Arun Nagarajan on 12/3/17.
//  Copyright © 2017 Arun Nagarajan. All rights reserved.
//

import UIKit
import DKImagePickerController
import FirebaseAuth
import Firebase

class PhotoViewController: UIViewController {

    var storageRef: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        storageRef = Storage.storage().reference()

        // Do any additional setup after loading the view.
    }
    @IBAction func selectPhoto() {
        let pickerController = DKImagePickerController()
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            
            for asset in assets {
                asset.originalAsset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    let imageFile = contentEditingInput?.fullSizeImageURL
                    let filePath = Auth.auth().currentUser!.uid +
                    "/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(imageFile!.lastPathComponent)"
                    // [START uploadimage]
                    self.storageRef.child(filePath)
                        .putFile(from: imageFile!, metadata: nil) { (metadata, error) in
                            if let error = error {
                                print("Error uploading: \(error)")
                                return
                            }
                            print(metadata!, filePath)
                    }
                    // [END uploadimage]
                })
                
            }
        }
        
        self.present(pickerController, animated: true) {}

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
