//
//  ViewController.swift
//  RealmDemoApp
//
//  Created by Martin Urciuoli on 22/11/2021.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    var realmDB: Realm!
    var tasks = [ToDoTask]()
    
    @IBOutlet weak var tasksTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .add, style: .done, target: self, action: #selector(addTask))
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "RealmDB"
        
        realmDB = try! Realm()
        
        print(realmDB.configuration.fileURL!)
        
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
    }
    
    func getTodos() {
        // Get all the data from the database
        let notes = realmDB.objects(ToDoTask.self)
        
        // Clear the model data array to prevent duplicates
        self.tasks.removeAll()
        
        // if the fetched data is not empty then add it to model data array and update the UI
        if ( !notes.isEmpty ) {
            for n in notes {
                self.tasks.append(n)
            }
            self.tasksTableView.reloadData()
        }
    }

    
    @objc func addTask() {
        let alertController = UIAlertController(title: "Add Note", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: .none)
        alertController.addAction(
            UIAlertAction(
                title: "Add",
                style: .default,
                handler: { (UIAlertAction) in
                    if let text = alertController.textFields?.first?.text {
                        print(text)
                        
                        // Add data to data model array
                        let oneTask = ToDoTask()
                        oneTask.taskid = UUID().uuidString
                        oneTask.tasknote = text
                        
                        self.tasks.append(oneTask)
                        
                        // Add data to database
                        try! self.realmDB.write {
                            self.realmDB.add(oneTask)
                        }
                        
                        // Update table View UI
                        self.tasksTableView.reloadData()
                    }
                }
            )
        )
        alertController.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
        present(alertController, animated: true, completion: nil)
    }
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = tasks[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell.textLabel?.text = item.tasknote
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskToModify = tasks[indexPath.row]
        let alertController = UIAlertController(
            title: "Update task ",
            message: nil,
            preferredStyle: .alert
        )
        
        alertController.addTextField(configurationHandler: .none)
        alertController.addAction(
            UIAlertAction(
                title: "OK",
                style: .default,
                handler: { (UIAlertAction) in
                    if let text = alertController.textFields?.first?.text {
                        if (!text.isEmpty) {
                            try!  self.realmDB.write({
                                taskToModify.tasknote = text
                            })
                            self.tasksTableView.reloadData()
                        }
                    }
                }
            )
        )
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let taskToDelete = tasks[indexPath.row]
            try! realmDB.write({
                realmDB.delete(taskToDelete)
                self.tasks.remove(at: indexPath.row)
                self.tasksTableView.deleteRows(at: [indexPath], with: .fade)
            })
        }
    }
    
    
}
