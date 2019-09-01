//
//  ImageProcess.swift
//  Floq
//
//  Created by Shadrach Mensah on 30/08/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import ImageIO
import FirebaseStorage
import CoreData

protocol ImageProcessDelegate:class {
    func imageReady(_ image:UIImage)
}

class ImageProcess{
    
    
    private static let _main = ImageProcess()
    
    private init(){
        cache.countLimit = 200
        
    }
    
    static var main:ImageProcess{
        return _main
    
        
    }
    
    private var dispatchedCalls:Set<String> = []
    private var callableHandlers:[UUID:String] = [:]
    private var ref:StorageReference!
    private var size:CGSize!
//    weak var delegate:ImageProcessDelegate?{
//        didSet{
//            guard let _ = delegate else {return}
//            downloadImage(ref: ref, size: size)
//        }
//    }
    
//    init(ref:StorageReference, size:CGSize){
//        self.ref = ref
//        self.size = size
//    }
    let cache =  NSCache<NSString, UIImage>()
    let stack = CoreDataStack.stack
    
    typealias Completion = (_ image:UIImage)-> Void
    let queue = DispatchQueue(label: "ImageProcess", qos: .background)
    
    func downsampleImage(at url:URL, size:CGSize)->UIImage{
        let option  = [kCGImageSourceShouldCache : false] as CFDictionary
        let source = CGImageSourceCreateWithURL(url as CFURL, option)!
        let scale = UIScreen.main.scale
        let maxDimensPix = max(size.width, size.height) * scale
        let downOpts = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                        kCGImageSourceShouldCacheImmediately: true, kCGImageSourceCreateThumbnailWithTransform: true,
                        kCGImageSourceThumbnailMaxPixelSize: maxDimensPix] as CFDictionary
        let dimg = CGImageSourceCreateThumbnailAtIndex(source, 0, downOpts)!
        return UIImage(cgImage: dimg)
    }
    
    func downSampleImage(data:Data, size:CGSize)->UIImage?{
        let option = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, option) else {return nil}
        let scale = UIScreen.main.scale
        let maxDimensPix = max(size.width, size.height) * scale
        let downOpts = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                        kCGImageSourceShouldCacheImmediately: true, kCGImageSourceCreateThumbnailWithTransform: true,
                        kCGImageSourceThumbnailMaxPixelSize: maxDimensPix] as CFDictionary
        
        let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downOpts)
        return (cgImage != nil) ?  UIImage(cgImage: cgImage!) : nil
    }
    
    func downloadImage(ref:StorageReference, size:CGSize,cellID:UUID, completion:@escaping Completion){
        if let thumnail = getCachedImage(ref.fullPath){
            completion(thumnail)
            cacheThumbnail(thumnail, ref: ref.fullPath)
            return
        }
        
        if dispatchedCalls.contains(ref.fullPath){
            return
        }
        dispatchedCalls.insert(ref.fullPath)
        callableHandlers.updateValue(ref.fullPath, forKey: cellID)
        queue.async {
            ref.getData(maxSize: .max) { (data, err) in
                if let err = err{
                    print("Image Process Error: \(err.localizedDescription)")
                    return
                }
                guard let data = data else {return}
                guard let image = self.downSampleImage(data: data, size: size) else {return}
                if (self.callableHandlers[cellID] == ref.fullPath){
                    completion(image)
                }
                self.cacheThumbnail(image, ref: ref.fullPath)
                self.saveThumnail(image, ref: ref.fullPath)
            }

        }
    }
    
    func retrieveImageFromCache(ref:String)->UIImage?{
        cache.object(forKey: ref as NSString)
    }
    
    func getCachedImage(_ ref:String)->UIImage?{
        if let image = retrieveImageFromCache(ref: ref){
            return image
        }
        let photoRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(ThumbnailImage.self)")
        let sort = NSSortDescriptor(key: "dateCreated", ascending: true)
        photoRequest.sortDescriptors = [sort]
        photoRequest.predicate = NSPredicate(format: "%K = %@","ref", ref)
        do {
            let thumbs = try CoreDataStack.stack.context.fetch(photoRequest)
            if let data = (thumbs.first as? ThumbnailImage)?.data{

                return UIImage(data: data)
            }
            
        } catch let error {
            print("Error in assigning Thumbnial: \(error.localizedDescription)")
        }
        return nil
    }
    
    func cacheThumbnail(_ image:UIImage, ref:String){
        cache.setObject(image, forKey: ref as NSString)
    }
    
    func saveThumnail(_ image:UIImage, ref:String){
        
        let thumb = ThumbnailImage(context:stack.context)
        thumb.data = image.pngData()
        thumb.ref = ref
        thumb.dateCreated = Date()
        stack.saveContext()
        
    }
    
    static func deleteThumbnails(){
        ImageProcess.batchDelete("\(ThumbnailImage.self)")
    }
    
    static func batchDelete(_ entity:String){
        let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchrequest)
        do {
            try CoreDataStack.stack.context.execute(deleteRequest)
        } catch let err {
            print("Error occurred deleting Batch: \(err.localizedDescription)")
        }
    }
    
}



extension UIImageView{
    
//    func loadImagewith(ref:StorageReference){
//        let size = bounds.size
//        DispatchQueue.global().async {
//            ImageProcess().downloadImage(ref: ref, size:size ) { (img) in
//                DispatchQueue.main.async {
//                    self.image = img
//                }
//            }
//        }
//    }
}
