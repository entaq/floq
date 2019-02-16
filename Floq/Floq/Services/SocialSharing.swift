//
//  SocialSharing.swift
//  Floq
//
//  Created by Shadrach Mensah on 16/02/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//
import FacebookShare



class SocialShare:NSObject{
    
    enum Platform{
        case facebook
        case twitter
    }
    
    public private (set) var platform:Platform
    
    init(platform:Platform) {
        self.platform =  platform
    }
    
    func share(image:UIImage){
        switch platform {
        case .facebook:
            createfacebookShare(image: image)
            break
        default:
            break
            
        }
    }
    
    private func createfacebookShare(image:UIImage){
        let photo = Photo(image: image, userGenerated:true)
        let content = PhotoShareContent(photos: [photo])
        do {
            guard let rootvc = UIApplication.shared.keyWindow?.rootViewController else {
                return
            }
            try ShareDialog<PhotoShareContent>.show(from: rootvc, content: content,mode:.shareSheet, completion: { (contentRes) in
                switch(contentRes){
                case .success( _):
                    let alert = UIAlertController.createDefaultAlert(Info.Titles.success.rawValue, "Photo was shared succesfully",.alert, "OK",.default, nil)
                    OperationQueue.main.addOperation {rootvc.present(alert, animated: true, completion: nil)}
                    break
                case .failed(let err):
                    let alert = UIAlertController.createDefaultAlert(Info.Titles.error.rawValue, err.localizedDescription,.alert, "OK",.default, nil)
                    OperationQueue.main.addOperation {rootvc.present(alert, animated: true, completion: nil)}
                    break
                default:
                    break
                }
            })
        } catch let err  {
            print("This error haapened: ",err.localizedDescription)
        }
    }
    
}



extension ShareDialog{
    
//    @discardableResult
//    public static func show(from viewController: UIViewController,
//                            content: Content,mode:ShareDialogMode,
//                            completion: ((ContentSharerResult<Content>) -> Void)? = nil) throws -> Self {
//        let shareDialog = self.init(content: content)
//        shareDialog.presentingViewController = viewController
//        shareDialog.completion = completion
//        shareDialog.mode = mode
//        try shareDialog.show()
//        return shareDialog
//    }
}
