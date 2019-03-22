//
//  CliqsCell.swift
//  Floq
//
//  Created by Mensah Shadrach on 12/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit
import FirebaseStorage

protocol CliqDelegate:class {
    func didJoinCliq(_ cliq:Bool, with id:String)
}

class CliqsCell: UICollectionViewCell {
    
    @IBOutlet weak var mavi1:AvatarImageView!
    @IBOutlet weak var mavi2:AvatarImageView!
    @IBOutlet weak var mavi3:AvatarImageView!
    @IBOutlet weak var mavi4:AvatarImageView!
    @IBOutlet weak var mavi5:AvatarImageView!
    @IBOutlet weak var membersAvatarStack: UIStackView!
    @IBOutlet weak var commentlbl: UILabel!
    @IBOutlet weak var numberLikeslbl: UILabel!
    @IBOutlet weak var usernamePhotoStack: UIStackView!
    @IBOutlet weak var numberOfCliqslbl: UILabel!
    @IBOutlet weak var commentStack: UIStackView!
    @IBOutlet weak var likeStack: UIStackView!
    @IBOutlet weak var avi: UIImageView!
    @IBOutlet weak var containerView: ContainerView!
    @IBOutlet weak var joinbutt: FButton!
    @IBOutlet weak var creator: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var imagevOverlay: UIView!
    weak var delegate:CliqDelegate?
    private var cliq:FLCliqItem?
    override func awakeFromNib() {
        super.awakeFromNib()
        commentStack.isHidden = true
        membersAvatarStack.isHidden = true
        likeStack.isHidden = true
        imageview.clipsToBounds = true
        avi.clipsToBounds = true
        mavi5.backgroundColor = .white
        avi.layer.cornerRadius = avi.frame.width / 2
        avi.layer.borderWidth = 2.0
        avi.layer.borderColor = UIColor.white.cgColor
        imageview.contentMode = .scaleAspectFill
        imageview.layer.cornerRadius = 5.0
        imagevOverlay.layer.cornerRadius = 5.0
    }
    
    func configureView(cliq:FLCliqItem, key:keys?) {
        self.cliq = cliq
        numberOfCliqslbl.isHidden = true
        let reference = Storage.floqPhotos.child(cliq.item.photoID)
        imageview.sd_setImage(with: reference, placeholderImage: nil)
        containerView.sendSubviewToBack(imageview)
        self.title.text = cliq.name
        guard let key = key else{return}
        switch key {
        case .mine:
            joinbutt.isHidden = true
            creator.isHidden = true
            avi.isHidden = true
            membersAvatarStack.isHidden = false
            configureMemberAvatar(followers: cliq.followers)
            break
        case .near:
            self.creator.text = cliq.item.user
            avi.setAvatar(uid: cliq.creatorUid)
            break
        default:
            break
        }
        
        if cliq.joined{
            joinbutt.isEnabled = false
            joinbutt.setTitle("Joined", for: .normal)
        }else{
            joinbutt.isEnabled = true
            joinbutt.setTitle("Join", for: .normal)
        }
    }
    func configureMemberAvatar(followers:Set<String>){
        let keys = Array<String>(followers)
        switch keys.count {
        case 1:
            mavi1.isHidden = false
            mavi2.isHidden = true
            mavi3.isHidden = true
            mavi4.isHidden = true
            mavi5.isHidden = true
             mavi1.setAvatar(uid: keys.first!)
        case 2:
            mavi1.isHidden = false
            mavi2.isHidden = false
            mavi3.isHidden = true
            mavi4.isHidden = true
            mavi5.isHidden = true
            mavi1.setAvatar(uid: keys.first!)
            mavi2.setAvatar(uid: keys[1])
            break
        case 3:
            mavi1.isHidden = false
            mavi2.isHidden = false
            mavi3.isHidden = false
            mavi4.isHidden = true
            mavi5.isHidden = true
            mavi1.setAvatar(uid: keys.first!)
            mavi2.setAvatar(uid: keys[1])
            mavi3.setAvatar(uid: keys[2])
            break
        case 4:
            mavi1.isHidden = false
            mavi2.isHidden = false
            mavi3.isHidden = false
            mavi4.isHidden = false
            mavi5.isHidden = true
            mavi1.setAvatar(uid: keys.first!)
            mavi2.setAvatar(uid: keys[1])
            mavi3.setAvatar(uid: keys[2])
            mavi4.setAvatar(uid: keys[3])
            break
        case 5:
            mavi1.isHidden = false
            mavi2.isHidden = false
            mavi3.isHidden = false
            mavi4.isHidden = false
            mavi5.isHidden = false
            mavi1.setAvatar(uid: keys.first!)
            mavi2.setAvatar(uid: keys[1])
            mavi3.setAvatar(uid: keys[2])
            mavi4.setAvatar(uid: keys[3])
            mavi5.image = UIImage.icon_addPhoto
            break
        default:
            mavi1.isHidden = true
            mavi2.isHidden = true
            mavi3.isHidden = true
            mavi4.isHidden = true
            mavi5.isHidden = true
            break
        }
    }
    
    func configureViewForSection(cliq:SectionableCliq){
        let cl = cliq.getFirstItem()
        let reference = Storage.floqPhotos.child(cl.item.photoID)
        imageview.sd_setImage(with: reference, placeholderImage:nil)
        containerView.sendSubviewToBack(imageview)
        self.title.text = cliq.sectionType.rawValue
        self.creator.isHidden = true
        avi.isHidden = true
        numberOfCliqslbl.isHidden = false
        joinbutt.isHidden = true
        if cliq.sectionType == .near{
            commentStack.isHidden = true
            likeStack.isHidden = true
            numberOfCliqslbl.text = "\(cliq.count()) public Cliqs"
        }else{
            
            numberOfCliqslbl.text = "\(cliq.count()) Cliqs"
            //commentStack.isHidden = false
            
            
        }
    }
    

    @IBAction func jointapped(_ sender: Any) {
        if let cliq = cliq{
            if !cliq.joined{
                
                DataService.main.joinCliq(cliq:cliq)
                joinbutt.setTitle("Joined", for: .normal)
                delegate?.didJoinCliq(true, with: cliq.id)
            }else{
                
            }
        }
    }
}


