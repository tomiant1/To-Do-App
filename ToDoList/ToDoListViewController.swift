//
//  ToDoListViewController.swift
//  ToDoList
//
/*
 MIT License
 
 Copyright (c) 2018 Gwinyai Nyatsoka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

protocol ToDoListDelegate: AnyObject {
    
    func update(componentToUpdate: ToDoItem, componentIndex: Int)
    
}

class ToDoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var toDoItems: [ToDoItem] = []

    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        // Footer view = last row in the table view separated from reusable cells above. Usually nil by default. This way we initialize it.
        
        tableView.tableFooterView = UIView()
        
        title = "To Do List"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        
        NotificationCenter.default.addObserver(self, selector: #selector(addNewTask(_ :)), name: NSNotification.Name.init("com.todoapp.addtask"), object: nil)
        
    }
    
    @objc func addNewTask(_ notification: NSNotification) {
        
        var toDoItem: ToDoItem!
        
        if let task = notification.object as? ToDoItem {
            
            toDoItem = task
            
        }
        
        else if let taskDic = notification.userInfo as NSDictionary? {
            
            guard let task = taskDic["Task"] as? ToDoItem else { return }
            
            toDoItem = task
            
        }
        
        else {
            
            return
            
        }
        
        toDoItems.append(toDoItem)
        
        toDoItems.sort(by: { $0.completionDate > $1.completionDate })
        
        tableView.reloadData()
        
    }
    
    @objc func addButtonTapped() {
        
        performSegue(withIdentifier: "AddTaskSegue", sender: nil)
        
    }
    
    @objc func editButtonTapped() {
        
        // If tapped, it changes the current editing state.
        
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing {
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editButtonTapped))
            
        }
        
        else {
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
            
        }
        
    }
    
    // For a case when we switch to another view controller but editing mode was still on. Example would be tapping + button when still editing Todo items.
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        tableView.setEditing(false, animated: false)
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return toDoItems.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItem")!
        
        cell.textLabel?.text = toDoItems[indexPath.row].name
        
        cell.detailTextLabel?.text = toDoItems[indexPath.row].isComplete ? "Completed" : "Incomplete"
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = toDoItems[indexPath.row]
        
        // performSegue can only pass one value to the sender so using tuple here.
        
        let toDoItemValues = (selectedItem, indexPath.row)
        
        performSegue(withIdentifier: "TaskDetailsSegue", sender: toDoItemValues)
        
    }
    
    // Method to delete a particular row of the tableView. Gets called when tableView.isEditing == true.
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, indexPath in
            
            self.toDoItems.remove(at: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
        }
        
        return [delete]
        
    }
    
    // This gets executed right BEFORE the 'perform segue' action.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TaskDetailsSegue" {
            
            guard let destinationVC = segue.destination as? ToDoDetailsViewController else { return }
            
            // Sender = pressed row in pre-segue view controller (not destinationVC!)
            
            guard let toDoValues = sender as? (ToDoItem, Int) else { return }
            
            // Assigning selected item to a property within the controller so we can display data (name, details, etc) of each specific item when we tap on it.
            
            destinationVC.toDoItem = toDoValues.0
            
            destinationVC.toDoIndex = toDoValues.1
            
            destinationVC.delegate = self
            
        }
        
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("com.todoapp.addtask"), object: nil)
        
    }
    
}

extension ToDoListViewController: ToDoListDelegate {
    
    func update(componentToUpdate: ToDoItem, componentIndex: Int) {
        
        toDoItems[componentIndex] = componentToUpdate
        
        tableView.reloadData()
        
    }
    
}


// HOW NOTIFICATIONS WORK?
// 1. Post notification from where you want to send the data via NotificationCenter.default.post method
// 2. Add observer for that notification where you want to receive the data via NotificationCenter.default.addObserver
// 3. In the above method, create a selector function and define that function
// 4. Create an appropriate data model and store notification.object in it as that data model
// 5. Now you can do whatever you want with it. In our case, you append that data to our array and push it into tableView and refresh the tableView.
