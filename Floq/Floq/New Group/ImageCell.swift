/**
 Copyright (c) 2016-present, Facebook, Inc. All rights reserved.
 
 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
import FirebaseUI


final class ImageCell: UICollectionViewCell {
    
    fileprivate let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 4.0
        view.layer.shadowRadius = 2
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        return view
    }()
    
    private let titlelabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.light)
        label.textColor = UIColor.white
        label.numberOfLines = 1
        return label
    }()
    
    private let imageOverlay:UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black
        v.alpha = 0.3
        return v
    }()
    
    private let join:BaseBarButton = {
        let j = BaseBarButton()
        j.addTarget(self, action: #selector(joinTapped), for: .touchUpInside)
        return j
    }()
    
    @objc func joinTapped(){
        print("Hello Wold world")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        //contentView.addSubview(imageOverlay)
        contentView.addSubview(titlelabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let iframe = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width - 30, height: bounds.height - 10)
        imageView.frame = iframe
        imageView.center = contentView.center
        imageOverlay.frame = iframe
        imageOverlay.center = contentView.center
        let labelheight:CGFloat = 30.0
        let frame = CGRect(x: 20, y: bounds.height - (labelheight + 8), width: bounds.width, height: labelheight)
        titlelabel.frame = frame
        
    }
    
    
    
    func setImage(reference: StorageReference,title:String?) {
        imageView.sd_setImage(with: reference, placeholderImage: nil)
        titlelabel.text = title
    }
    
}

