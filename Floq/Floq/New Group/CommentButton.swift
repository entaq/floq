//
//  CommentButton.swift
//  Floq
//
//  Created by Shadrach Mensah on 15/08/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class CommentButton: UIButton {

    private lazy var image:UIImageView = {
        let img = UIImageView(frame:.zero)
        img.image = #imageLiteral(resourceName: "comments_white")
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private lazy var notif:UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .orangeRed
        view.clipsToBounds = true
        //view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var broadcast:Bool = false{
        didSet{
            //notif.isHidden = !broadcast
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(image)
        addSubview(notif)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            image.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            image.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            image.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            notif.topAnchor.constraint(equalTo: topAnchor, constant: -7.5),
            notif.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 7.5),
            notif.heightAnchor.constraint(equalToConstant: 15),
            notif.widthAnchor.constraint(equalToConstant: 15)
        ])
        notif.layer.cornerRadius = 7.5
    }
}
