//
//  UserProfileVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 01/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import FirebaseStorage
import FacebookLogin
import FacebookCore
import SDWebImage

class UserProfileVC: UIViewController {

    @IBOutlet weak var settingsContainer: UIView!
    @IBOutlet weak var numOfFollowing: UILabel!
    @IBOutlet weak var followingView: UIView!
    @IBOutlet weak var numofFollowers: UILabel!
    @IBOutlet weak var followerView: UIView!
    @IBOutlet weak var numOfClicks: UILabel!
    @IBOutlet weak var clickCountView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var editImageButt:UIButton!
    var userID:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
          navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        userID = UserDefaults.uid
        
        imageView.setAvatar(uid: userID)
        DataService.main.getUserWith(userID) { (user, err) in
            if let user = user as? FLUser{
                self.title = user.username.capitalized
                
            }
        }
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func changeAvatarPressed(_ sender: Any) {
        
        let alert = UIAlertController.createDefaultAlert("Change Avatar", "", .actionSheet, "Cancel",.cancel, nil)
        let pick = UIAlertAction(title: "Select From Photos", style: .default) { (ac) in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            self.present(picker, animated:true, completion: nil)
        }
        
        let camera = UIAlertAction(title: "Take Photo", style: .default) { (ac) in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            self.present(picker, animated:true, completion: nil)
        }
        alert.addAction(pick)
        alert.addAction(camera)
        present(alert, animated: true, completion: nil)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension UserProfileVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage{
            imageView.image = image
            let loader = LoaderView(frame: imageView.frame, offset: 25)
            view.addSubview(loader)
            Storage.saveAvatar(image: image) { (succ, err) in
                loader.removeFromSuperview()
                if succ{
                    print("Successfully uploaded")
                }else{
                    print("failed to set image")
                    self.imageView.setAvatar(uid: self.userID)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
