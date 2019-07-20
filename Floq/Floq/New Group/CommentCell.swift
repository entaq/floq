//
//  CommentCell.swift
//  Floq
//
//  Created by Shadrach Mensah on 17/07/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var timelbl: UILabel!
    @IBOutlet weak var commentlable: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 15
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ comment:Comment){
        timelbl.text = comment.timestamp.localize()
       usernameLabel.text = comment.commentor
        profileImageView.setAvatar(uid: comment.commentorID)
        commentlable.text = comment.body
    }
    
}
