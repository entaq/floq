//
//  UserListVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 02/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class UserListVC: UITableViewController {

    var list:[Aliases.stuple]!
    var cliq:FLCliqItem!
    override func viewDidLoad() {
        super.viewDidLoad()
          navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        title = "Cliq Details"
        
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier:String(describing: UserListCell.self), for: indexPath) as? UserListCell{
            let tup = list[indexPath.row]
            cell.configure(id: tup.0, name: tup.1, count:tup.2)
            return cell
        }

        

        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Members who have added photos to this Cliq"
    }
    
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if list.isEmpty{
           return "Cliq created on \(cliq.timestamp.toStringwith(.month_day_year)) by \(cliq.creatorName)"
        }
        return """
        Cliq created on \(cliq.timestamp.toStringwith(.month_day_year)) by \(cliq.creatorName)
        
        You can block users and their content by swiping left on their user name, this action can be undone.
        """
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let item = list[indexPath.row]
        if item.0 == UserDefaults.uid{return false}
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let id = self.list[indexPath.row].0
        let blockAction:UITableViewRowAction
        if App.user != nil && App.user!.hasBlocked(user: id){
           blockAction = UITableViewRowAction(style: .normal, title: "Unblock") { (ac, indexpath) in
                
                DataService.main.unBlockUser(id: id, completion: { (success, err) in
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
                
                DataService.main.blockUser(id: id, completion: { (success, err) in
                    if success{
                        Subscription.main.post(suscription: .invalidatePhotos, object: id)
                        tableView.reloadData()
                    }else{
                        print("Error occurred blocking: \(err ?? "Unknown")")
                    }
                })
                
            }
        }
            
        
        return [blockAction]
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
