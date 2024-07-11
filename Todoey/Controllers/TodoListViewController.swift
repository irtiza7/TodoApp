//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    private let dataService: DatabaseService = DatabaseService.shared
    private var todos: [Todo] = []
    
    public var category: Category?
    
    @IBOutlet weak var todoSearchBar: UISearchBar!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.todoSearchBar.delegate = self
        self.fetchTodosAgainstCategoryName()
//        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    }
    
    @IBAction func addTodoPressed(_ sender: UIBarButtonItem) {
        var uiTextField = UITextField()
        
        let alertViewController = UIAlertController(title: "Add new todoey", message: "...", preferredStyle: .alert)
        alertViewController.addTextField { textField in
            uiTextField = textField
        }
        
        let alertAction = UIAlertAction(title: "Add", style: .default) { action in
            guard let todoTitle = uiTextField.text else {return}
            guard todoTitle != "" else {return}
            
            let newTodo = Todo(context: self.dataService.dbContext)
            newTodo.title = todoTitle
            newTodo.isDone = false
            newTodo.parentCategory = self.category!
            
            self.todos.append(newTodo)
            self.saveTodosIntoDB()
            self.tableView.reloadData()
        }
        alertViewController.addAction(alertAction)
        present(alertViewController, animated: true)
    }
}

// MARK: - Data Model Manipulation Methods

extension TodoListViewController {
    private func fetchTodosFromDB() {
        guard let todosArray = self.dataService.fetchAllTodosFromDB() else {return}
        self.todos = todosArray
    }
    
    private func saveTodosIntoDB() {
        self.dataService.saveDataToDB()
    }
    
    private func updateTodoInDB() {
        self.dataService.updateDataInDB()
    }
    
    private func deleteTodoFromDB(todoIndex: Int) {
        defer{
            self.todos.remove(at: todoIndex)
        }
        self.dataService.deleteTodoFromDB(todo: self.todos[todoIndex])
    }
    
    private func fetchTodosAgaintTitleAndCategory(title: String, categoryName: String) {
        guard title != "" else {return}
        guard let todos = self.dataService.fetchTodosAgainstTitle(title: title, categoryName: categoryName) else {
            self.todos = []
            return
        }
        self.todos = todos
    }
    
    private func fetchTodosAgainstCategoryName() {
        guard let todos = self.dataService.fetchTodosAgainstCategoryName(categoryName: self.category!.name!) else {return}
        self.todos = todos
        print(todos)
    }
}

// MARK: - TableView Data Source Methods

extension TodoListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = self.todos[indexPath.row].title
        cell.accessoryType = self.todos[indexPath.row].isDone ? .checkmark : .none
        return cell
    }
}

// MARK: - TableView Delegate Methods

extension TodoListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.todos[indexPath.row].isDone = !self.todos[indexPath.row].isDone
        tableView.deselectRow(at: indexPath, animated: true)
        self.updateTodoInDB()
        tableView.reloadData()
    }
}

// MARK: - Search Bar Delegate Methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let title = searchBar.text else {return}
        
        self.fetchTodosAgaintTitleAndCategory(title: title, categoryName: self.category!.name!)
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.todoSearchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.todoSearchBar.showsCancelButton = false
        self.todoSearchBar.text = nil
        self.todoSearchBar.resignFirstResponder()
        
        self.fetchTodosAgainstCategoryName()
        self.tableView.reloadData()
    }
}
