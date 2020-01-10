//
//  UserListVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 02/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class UserListVC: UITableViewController {

    var list:[String:(String,Int)]!
    var cliq:FLCliqItem!
    var users:[FLUser] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .groupTableViewBackground
          navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        title = "Cliq Details"
        DataService.main.getFollowers(ids: cliq.followers) { users, err in
            self.users = users
            if let index = (users.firstIndex{$0.uid == UserDefaults.uid}){
                self.users.swapAt(index, 0)
            }
            self.tableView.reloadData()
        }
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        App.setDomain(.UserList)
        
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier:String(describing: UserListCell.self), for: indexPath) as? UserListCell{
            let user = users[indexPath.row]
            let listed = list[user.uid]
            cell.configure(id: user.uid, name: user.username, count:listed?.1 ?? 0)
            if indexPath.row == 0{
                cell.accessoryType = .disclosureIndicator
            }
            return cell
        }

        

        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Followers of this Cliq"
    }
    
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if users.isEmpty{
           return "Cliq created on \(cliq.timestamp.toStringwith(.month_day_year)) by \(cliq.creatorName)"
        }
        return """
        Cliq created on \(cliq.timestamp.toStringwith(.month_day_year)) by \(cliq.creatorName)
        
        You can block users and their content by swiping left on their user name, this action can be undone.
        """
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let item = users[indexPath.row]
        if item.uid == UserDefaults.uid{return false}
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let user = self.users[indexPath.row]
        let blockAction:UITableViewRowAction
        if App.user != nil && App.user!.hasBlocked(user: user.uid){
           blockAction = UITableViewRowAction(style: .normal, title: "Unblock") { (ac, indexpath) in
                
            DataService.main.unBlockUser(id: user.uid, completion: { (success, err) in
                    if success{
                        Subscription.main.post(suscription: .invalidatePhotos, object: nil)
                        tableView.reloadData()
                    }else{
                        print("Error occurred blocking: \(err ?? "Unknown")")
                    }
                })
            
            }
            blockAction.backgroundColor = .seafoamBlue
        }else{
            blockAction = UITableViewRowAction(style: .destructive, title: "Block") { (ac, indexpath) in
                
                DataService.main.blockUser(id: user.uid, completion: { (success, err) in
                    if success{
                        Subscription.main.post(suscription: .invalidatePhotos, object: user.uid)
                        tableView.reloadData()
                    }else{
                        print("Error occurred blocking: \(err ?? "Unknown")")
                    }
                })
                
            }
        }
            
        
        return [blockAction]
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        if user.uid == UserDefaults.uid{
            let vc = PhotosVC(cliq: cliq, id:cliq.id)
            vc.isMyPhotos = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
