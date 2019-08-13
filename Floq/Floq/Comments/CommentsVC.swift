//
//  CommentsVC.swift
//  Floq
//
//  Created by Shadrach Mensah on 17/07/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class CommentsVC: UIViewController {
    
    private lazy var tableView:UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.isScrollEnabled = true
        table.alwaysBounceVertical = true
        table.register(UINib(nibName: "\(CommentCell.self)", bundle: nil), forCellReuseIdentifier: "\(CommentCell.self)")
        table.register(UINib(nibName: "\(LoadMoreCells.self)", bundle: nil), forCellReuseIdentifier: "\(LoadMoreCells.self)")
        return table
    }()
    
    var photoID:String!
    private var engine: CommentEngine!
    var exhausted = false
    var hasNotch:Bool = false
    
    private lazy var commentView:UIButton = { [unowned self] by in
       let view = UIButton(frame: .zero)
        view.backgroundColor = .seafoamBlue
        view.addTarget(self, action: #selector(commentPressed(_:)), for: .touchUpInside)
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        view.setTitleColor(.white, for: .normal)
        view.setTitle("Add Comment", for: .normal)
        return view
    }(())
    
    private lazy var commentTextBox:UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = .systemFont(ofSize: 14, weight: .regular)
        textField.textColor = .darkGray
        textField.placeholder = "Comment..."
        textField.borderStyle = .line
        textField.backgroundColor = .red
        return textField
    }()
    
    private var mock:Comment.MockData = Comment.MockData()
    
    init(id:String){
        super.init(nibName: nil, bundle: nil)
        photoID = id
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        engine = CommentEngine(photo: photoID)
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(commentView)
        layout()
        watchComments()
        // Do any additional setup after loading the view.
    }
    
    
    func watchComments(){
        engine.watchForComments { (err) in
            if err != nil{
                SmartAlertView(text: err!.localizedDescription).show(5)
            }else{
                self.tableView.reloadData()
                self.exhausted = self.engine.exhausted
            }
        }
    }
    
    func layout(){
        let inset:CGFloat = hasNotch ? 40 : 0
        commentView.layout{
            $0.bottom == view.bottomAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.height |=| (60 + inset)
        }
        
        tableView.layout{
            $0.top == view.topAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == commentView.topAnchor
        }
        commentView.titleEdgeInsets = hasNotch ? UIEdgeInsets(top: 0, left: 0, bottom: 20, right:  0) : UIEdgeInsets.zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //let inset:CGFloat = hasNotch ? 40 : 0
        //tableView.frame = CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.width, height: view.frame.height - (60 + inset)))
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    @objc func commentPressed(_ sender:UIButton){
        let commentvc = AddCommentVC(hasNotch)
        commentvc.delegate = self
        parent?.present(commentvc, animated: true, completion: nil)
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



extension CommentsVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if engine.comments.isEmpty{
            let view = UIView(frame: .zero)
            view.backgroundColor = .white
            let activity = UIActivityIndicatorView(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
            activity.style = .whiteLarge
            activity.tintColor = .seafoamBlue
            view.addSubview(activity)
            tableView.backgroundView = view
            activity.center = view.center
            activity.startAnimating()
        }
        if exhausted{
            return engine.comments.count
        }else{
            return engine.comments.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == engine.comments.endIndex{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "\(LoadMoreCells.self)", for: indexPath) as? LoadMoreCells{
                cell.reset()
                return cell
            }
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: "\(CommentCell.self)", for: indexPath) as? CommentCell{
            let comment = engine.comments[indexPath.row]
            cell.configure(comment)
            return cell
        }
        return CommentCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == engine.comments.endIndex{
            return 40
        }
        let comment = engine.comments[indexPath.row]
        let width = tableView.frame.width - 62
        let txtheight = comment.body.height(withConstrainedWidth: width, font: .systemFont(ofSize: 13, weight: .regular))
        return txtheight + 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == engine.comments.endIndex{
            if let cell = tableView.cellForRow(at: indexPath) as? LoadMoreCells{
                cell.pressed()
                watchComments()
            }
        }
    }
}


//FOr testing Remove at integration Testing

extension CommentsVC:CommentProtocol{
    func didPost(_ comment: String) {
        
        SmartAlertView(text: "Sending comment....").show()
        //return
        if let _ = appUser{
            let raw = Comment.Raw(ref: nil, body: comment, photoID: photoID)
            engine.postAComment(raw) { (err) in
                if err != nil{
                   SmartAlertView(text: err!.localizedDescription).show()
                }else{
                    self.tableView.reloadData()
                }
            }
            
        }
        
    }
    
    
    
}
