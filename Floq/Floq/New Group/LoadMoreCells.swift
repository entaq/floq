//
//  LoadMoreCells.swift
//  Floq
//
//  Created by Shadrach Mensah on 20/07/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class LoadMoreCells: UITableViewCell {

    @IBOutlet weak var lable: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.isHidden = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func pressed(){
        lable.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func reset(){
        lable.isHidden = false
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
}
