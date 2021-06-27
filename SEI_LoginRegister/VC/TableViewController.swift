//
//  TableViewController.swift
//  SEI_LoginRegister
//
//  Created by Marko Milosavljevic on 26.06.21.
//


import UIKit

class TableViewController: UITableViewController {

    private var todoItems = [ToDoItem]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = "To-Do List"
        self.navigationController?.navigationBar.tintColor = UIColor(named: "highlight")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(didTapAddItemButton))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SB_ToDO_cell")
    }
    


    // MARK: - Table view data sourc

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SB_ToDO_cell", for: indexPath)

                if indexPath.row < todoItems.count
                {
                    let item = todoItems[indexPath.row]
                    cell.textLabel?.text = item.title
                  
                }

                return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
        
        if indexPath.row < todoItems.count
        {
            todoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
        }
    }
    

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
    
    

    @objc func didTapAddItemButton(_ sender: Any) {
        
            let alert = UIAlertController(
                title: "New Task",
                message: "Insert title of new task:",
                preferredStyle: .alert)

            alert.addTextField(configurationHandler: nil)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                if let title = alert.textFields?[0].text
                {
                    self.addNewToDoItem(title: title)
                }
            }))
        
            self.present(alert, animated: true, completion: nil)
            
    }
    
    private func addNewToDoItem(title: String)
        {
            let newIndex = todoItems.count
            todoItems.append(ToDoItem(title: title))
            tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .top)
        }
    
}
