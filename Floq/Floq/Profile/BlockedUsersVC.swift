//
//  BlockedUsersVC.swift
//  Floq
//
//  Created by Shadrach Mensah on 14/05/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import UIKit

class BlockedUsersVC: UITableViewController {
    
    private var users:[FLUser] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.isEditing = true
        //tableView.allowsSelectionDuringEditing = true
        DataService.main.getBlockedUsers { (users) in
            self.users = users
            self.tableView.reloadData()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //#warning ("Incomplete implementation, return the number of rows")
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let user = users[indexPath.row]
        cell.textLabel?.text = user.username
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let user = self.users[indexPath.row]
        let unblockAction = UITableViewRowAction(style: .normal, title: "Unblock") { (ac, indexpath) in
            DataService.main.unBlockUser(id: user.uid, completion: { (success, err) in
                if success{
                    self.users.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .bottom)
                }else{
                    print("Error occurred blocking: \(err ?? "Unknown")")
                }
            })
        }
        unblockAction.backgroundColor = .seafoamBlue
        return [unblockAction]
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .insert
    }
    
//    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "BLOCKED LIST"
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if users.isEmpty{
            return "You have no user on your block list"
        }
        return "Swipe left to unblock a user"
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
