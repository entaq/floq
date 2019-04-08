//
//  UIKitModules+Extensions.swift
//  Floq
//
//  Created by Mensah Shadrach on 01/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit
import SDWebImage.SDImageCache
import FirebaseStorage.FIRStorage


extension UIViewController{
    
    func add(_ child: UIViewController, to parentView:UIView? = nil) {
        addChild(child)
        if let v = parentView{
            v.addSubview(child.view)
        }else{
            view.addSubview(child.view)
        }
        child.didMove(toParent: self)
    }
    func removeFrom() {
        guard parent != nil else {
            return
        }
        
        willMove(toParent: nil)
        removeFromParent()
        
        view.removeFromSuperview()
    }
    
    public class var identifier:String{
        return String(describing: self)
    }
}

extension UIView{
    
    class func listAdapterEmptyView(superView:UIView, info:Info.Messages)->UIView{
        let view = UIView(frame: superView.frame)
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: view.frame.height)))
        label.numberOfLines = 10
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.text = info.rawValue
        label.center = view.center
        view.addSubview(label)
        return view
    }
}


extension UIImage{
    
    public static var placeholder:UIImage{
        return UIImage(named: "imageplaceholder")!
    }
    
    public static var loading:UIImage{
        return UIImage.gif(asset: "rippleAnim") ?? .placeholder
    }
    
    public static var myphoto:UIImage{
        let ref = Storage.profilePhotos.child(UserDefaults.uid)
        let img = SDImageCache.shared().imageFromCache(forKey: ref.fullPath)
        return img ?? .placeholder
    }
    
    public static var icon_menu:UIImage{
        return UIImage(named: "icon_account")!
    }
    
    public static var icon_addPhoto:UIImage{
        return UIImage(named: "addphoto")!
    }
    
    public static var icon_app_rounded:UIImage{
        return UIImage(named:"icon_app_rounded")!
    }
    
    public static var icon_app:UIImage{
        return UIImage(named:"AppIcon")!
    }
    
    public static var icon_like:UIImage{
        return UIImage(named:"like")!
    }
    
    public static var icon_unlike:UIImage{
        return UIImage(named:"empty_like")!
    }
    
    public static var icon_flag:UIImage{
        return UIImage(named: "flag")!
        
    }
    
    func dataFromJPEG()-> Data?{
        var compression:CGFloat = 1
        if let data = jpegData(compressionQuality: compression){
            if data.count < ImageSizes.min.rawValue{
                compression = 1
                return jpegData(compressionQuality: compression)
            }
            if data.count < ImageSizes.medium.rawValue{
                compression = 0.8
                return jpegData(compressionQuality: compression)
            }
            if data.count < ImageSizes.max.rawValue{
                compression = 0.5
                return jpegData(compressionQuality: compression)
            }
            
            compression = 0.3
            return jpegData(compressionQuality: compression)
            
        }
        return nil
    }
    
    
}

extension UIStoryboard{
    
    public static var main:UIStoryboard{
        return UIStoryboard(name: "Main", bundle: .main)
    }
}

extension UIColor{
    
    public static var globalbackground:UIColor{
        return UIColor(red: 232/255, green: 232/255, blue: 240/255, alpha: 1)
    }
    
    public static var barTint:UIColor{
        return UIColor(red: 41/255, green: 46/255, blue: 46/255, alpha: 1)
    }
    
    @nonobjc class var slate: UIColor {
        return UIColor(red: 85.0 / 255.0, green: 98.0 / 255.0, blue: 112.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var cloudyBlue: UIColor {
        return UIColor(red: 175.0 / 255.0, green: 188.0 / 255.0, blue: 201.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var seafoamBlue: UIColor {
        return UIColor(red: 78.0 / 255.0, green: 205.0 / 255.0, blue: 196.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var white: UIColor {
        return UIColor(white: 1.0, alpha: 1.0)
    }
    
    @nonobjc class var pear: UIColor {
        return UIColor(red: 199.0 / 255.0, green: 244.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var deepRose: UIColor {
        return UIColor(red: 196.0 / 255.0, green: 77.0 / 255.0, blue: 88.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var orangeRed: UIColor {
        return UIColor(red: 254.0 / 255.0, green: 56.0 / 255.0, blue: 36.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var slate55: UIColor {
        return UIColor(red: 85.0 / 255.0, green: 97.0 / 255.0, blue: 112.0 / 255.0, alpha: 0.55)
    }
    
    @nonobjc class var charcoal: UIColor {
        return UIColor(red: 41.0 / 255.0, green: 46.0 / 255.0, blue: 46.0 / 255.0, alpha: 1.0)
    }
    
    
}


extension UIAlertController{
    
    class func createDefaultAlert(_ title:String, _ message:String, _ style:UIAlertController.Style = .alert, _ actionTitle:String, _ actionStyle:UIAlertAction.Style = .default, _ handler: CompletionHandlers.alert?) -> UIAlertController{
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: actionTitle, style: actionStyle, handler: handler)
        alert.addAction(action)
        return alert
    }
    
    class func createDefaultAlert(_ title:Info.Titles, _ message:Info.Messages, _ style:UIAlertController.Style = .alert, _ actionTitle:Info.Action, _ actionStyle:UIAlertAction.Style = .default, _ handler: CompletionHandlers.alert?) -> UIAlertController{
        
        let alert = UIAlertController(title: title.rawValue, message: message.rawValue, preferredStyle: style)
        let action = UIAlertAction(title: actionTitle.rawValue, style: actionStyle, handler: handler)
        alert.addAction(action)
        return alert
    }
}


extension Date{
    
    
    func toStringwith(_ format:DateFormats)->String{
        let dateFomater = DateFormatter()
        dateFomater.dateStyle = .medium
        dateFomater.locale = Locale.current
        dateFomater.timeZone = TimeZone.current
        dateFomater.dateFormat = format.rawValue
        return dateFomater.string(from: self)
    }
    
    public var unix_ts:Int{
        return Int(timeIntervalSince1970)
    }
    
    public var nextDay:Date{
        let BASE = 3600 * 24
        return addingTimeInterval(TimeInterval(BASE))
    }

}



extension UIScreen{
    
    enum Handle{
        case xmax_xr
        case xs_x
        case pluses
        case eight_lower
        case fives
        case lowly
    }
    
    func screenType()->Handle{
        let height = UIScreen.main.bounds.height
        
        if height > 890{
            return .xmax_xr
        }
        if height > 800 {
            return .xs_x
        }
        
        if height > 700 {
            return .pluses
        }
        
        if height > 650 {
            return .eight_lower
        }
        
        if height > 550 {
            return .fives
        }
        
        return .lowly
    }
}


extension UIApplication{
    
    class func openSettings(){
        if let seturl = URL(string: UIApplication.openSettingsURLString){
            if UIApplication.shared.canOpenURL(seturl){
                UIApplication.shared.open(seturl, options: [:]) { (success) in
                    print("Sucess")
                }
            }
        }
        
    }
}
