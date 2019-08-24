//
//  PhotoEmptyView.swift
//  Floq
//
//  Created by Shadrach Mensah on 22/08/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

public final class PhotoEmptyView:UIView{
    
    private lazy var imageView:UIImageView = {
        let imagev = UIImageView(frame: .zero)
        imagev.contentMode = .scaleAspectFit
        imagev.image = UIImage.gif(data: self.data!)
        return imagev
    }()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        //backgroundColor = .red
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var data:Data?{
        do {
            let imageData = try Data(contentsOf: Bundle.main.url(forResource: "flickr", withExtension: "gif")!)
            return imageData
        }catch let err{
            print(err.localizedDescription)
        }
        return nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layout{
            $0.top == topAnchor
            $0.bottom == bottomAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
        }
        
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        //imageView.image = UIImage.gif(data: data!)
    }
}
