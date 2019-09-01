//
//  AddCommentVC.swift
//  Floq
//
//  Created by Shadrach Mensah on 19/07/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

//@for testing
protocol CommentProtocol:class {
    func didPost(_ comment:String)
}

class AddCommentVC: UIViewController {
    
    private var hasNotch = false
    
    private lazy var bar:UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .seafoamBlue
        return view
    }()
    
    weak var delegate:CommentProtocol?
    
    private lazy var textView:UITextView = {
        let view = UITextView(frame: .zero)
        view.font = .systemFont(ofSize: 15, weight: .regular)
        view.textColor = .gray
        view.backgroundColor = .white
        view.tintColor = .seafoamBlue
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        return view
    }()
    
    private lazy var sendButton:UIButton = { [unowned self] by in
         let button = UIButton(frame: .zero)
        button.backgroundColor = .clear
        //button.layer.cornerRadius = 20
        button.clipsToBounds = true
        //button.setTitleColor(.seafoamBlue, for: .normal)
        button.setImage(#imageLiteral(resourceName: "send-white"), for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(postComment(_:)), for: .touchUpInside)
        return button
    }(())
    
    private lazy var cancelButton:UIButton = { [unowned self] by in
        let button = UIButton(frame: .zero)
        //button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Cancel", for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(dismiss(_:)), for: .touchUpInside)
        return button
    }(())

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.groupTableViewBackground
        view.addSubview(bar)
        view.addSubview(textView)
        bar.addSubview(sendButton)
        bar.addSubview(cancelButton)
        bar.subviews.forEach{$0.translatesAutoresizingMaskIntoConstraints = false}
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -16),
            sendButton.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: 0),
            sendButton.heightAnchor.constraint(equalToConstant: 40),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            cancelButton.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 16),
            cancelButton.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -10),
            cancelButton.heightAnchor.constraint(equalToConstant: 30),
            cancelButton.widthAnchor.constraint(equalToConstant: 80),
        ])
        // Do any additional setup after loading the view.
    }
    
    
    init(_ hasNotch:Bool){
       self.hasNotch = hasNotch
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let height:CGFloat = hasNotch ? 100 : 80
        bar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height:height)
        textView.frame = CGRect(x: 16, y: hasNotch ? 120 : 100, width: view.frame.width - 32, height: view.frame.height * 0.30)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cancelButton.isHidden = false
        sendButton.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelButton.isHidden = true
        sendButton.isHidden = true
        
    }
    
    @objc func postComment(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
        delegate?.didPost(textView.text)
    }
    
    @objc func dismiss(_ sender:UIButton){
        dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
