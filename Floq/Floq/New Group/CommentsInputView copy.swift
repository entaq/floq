//
//  CommentsInputView.swift
//  
//
//  Created by Shadrach Mensah on 29/07/2019.
//

import UIKit

protocol CommentInputViewDelegate:class {
    func shouldAdjustFrame(_ increased:Bool)
    func postTapped(_ text:String)
}
class CommentsInputView: UIView {
    
    fileprivate var height = 30
    weak var delegate:CommentInputViewDelegate?
    let font = UIFont.systemFont(ofSize: 16, weight: .regular)
    lazy var textView:UITextView = { [unowned self] by in
        let text = UITextView(frame: .zero)
        text.backgroundColor = .clear
        text.font = font
        text.textColor = .darkGray
        text.tintColor = .seafoamBlue
        text.delegate = self
        return text
    }(())
    
    fileprivate lazy var postButton:UIButton = { [unowned self] by in
        let button = UIButton(frame: .zero)
        button.setTitleColor(.darkGray, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(postTapped(_:)), for: .touchUpInside)
        button.setTitle("Post", for: .normal)
        return button
    }(())
    fileprivate lazy var label:UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "add comment"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        initialize()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initialize(){
        self.backgroundColor = .white
        addSubview(label)
        self.addSubview(textView)
        addSubview(postButton)
        layer.cornerRadius = 19
        clipsToBounds = true
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
        height =  Int(textView.text.height(withConstrainedWidth: bounds.width, font: font))
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.layout{
            $0.leading == leadingAnchor + 8
            $0.bottom == bottomAnchor - 4
            $0.top == topAnchor + 4
            $0.trailing == postButton.leadingAnchor - 4
        }
        postButton.layout{
            $0.trailing == trailingAnchor - 8
            $0.bottom == bottomAnchor - 4
            $0.width |=| 40
            $0.height |=| 30
        }
        textView.layout{
            $0.leading == leadingAnchor + 8
            $0.bottom == bottomAnchor - 4
            $0.top == topAnchor + 4
            $0.trailing == postButton.leadingAnchor - 4
        }
    }
    
    
    
    @objc private func postTapped(_ sender:UIButton){
        delegate?.postTapped(textView.text)
    }

}



extension CommentsInputView:UITextViewDelegate{
   
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == .empty{
            postButton.isEnabled = false
            postButton.setTitleColor(.darkGray, for: .normal)
            label.isHidden = false
        }
        else{
            postButton.isEnabled = true
            postButton.setTitleColor(.seafoamBlue, for: .normal)
            label.isHidden = true
        }
        let textHieght = textView.text.height(withConstrainedWidth: bounds.width, font: font)
        if Int(textHieght) != height {
            
            delegate?.shouldAdjustFrame(Int(textHieght) > height)
            height = Int(textHieght)
        }
        
    }
    
}
