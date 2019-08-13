//
//  FIRStorage+Extensions.swift
//  Floq
//
//  Created by Mensah Shadrach on 01/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import FirebaseStorage
import SDWebImage

extension Storage{
    /*
     Reference a folder indicated by the field which exist or will be created in the base storaage
     */
    class func reference(_ ref:References)->StorageReference{
        return storage().reference().child(ref.rawValue)
    }
    
    public class var floqPhotos:StorageReference{
        return reference(.storageFloqs)
    }
    
    public class var profilePhotos:StorageReference{
        return reference(.userProfilePhotos)
    }
    
    class func saveAvatar(image:UIImage, completion:@escaping CompletionHandlers.storage){
        let data = image.dataFromJPEG()
        if data != nil{
            let uid = UserDefaults.standard.string(forKey: Fields.uid.rawValue)!
            let ref = reference(.userProfilePhotos).child(uid)
            ref.putData(data!, metadata: nil) { (meta, err) in
                
                if err == nil{
                    let cache = SDImageCache.shared()
                    cache.removeImage(forKey: ref.fullPath, withCompletion: {
                        cache.store(image, forKey: ref.fullPath, completion: nil)
                    })
                    completion(true,nil)
                }else{
                    completion(false,err!.localizedDescription)
                }
            }
        }else{
            completion(false,"Unable to convert image data")
        }
    }
}


extension SDImageCache{
    
    class func invalidateProfiles(){
        let prof = DataService.profileIDs
        for p in prof{
            shared().removeImage(forKey: Storage.profilePhotos.child(p).fullPath, withCompletion: nil)
        }
    }
}


extension UIImageView{
    
    func setAvatar(uid:String){
        let storageRef = Storage.reference(.userProfilePhotos).child(uid)
        sd_setImage(with: storageRef, placeholderImage: .placeholder) { (img, err, type, ref) in
            DataService.profileIDs.insert(uid)
        }
        //sd_setImage(with: storageRef, placeholderImage: UIImage.placeholder)
    }
    
    
}


