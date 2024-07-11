//
//  CategoryViewControllerTableViewController.swift
//  Todoey
//
//  Created by Dev on 7/10/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit

class CategoryViewControllerTableViewController: UITableViewController {
    
    private let databaseService = DatabaseService.shared
    private var categories: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchAllCategoriesFromDB()
    }
    
    @IBAction func addCategoryButtonPressed(_ sender: UIBarButtonItem) {
        var uiTextField = UITextField()
        
        let alertVC: UIAlertController = UIAlertController(title: "Add Category", message: nil, preferredStyle: .alert)
        alertVC.addTextField() { (textField: UITextField) in
            uiTextField = textField
        }
        
        let alertAction: UIAlertAction = UIAlertAction(title: "Add", style: .default) {
            (action) in
            guard let categoryTitle = uiTextField.text else {return}
            guard categoryTitle != "" else {return}
            
            let newCategory = Category(context: self.databaseService.dbContext)
            newCategory.name = categoryTitle
            
            self.categories.append(newCategory)
            self.saveCategoryIntoDB()
            self.tableView.reloadData()
        }
        
        alertVC.addAction(alertAction)
        present(alertVC, animated: true)
    }
}

// MARK: - Data Model Manipulation Methods

extension CategoryViewControllerTableViewController {
    private func saveCategoryIntoDB() {
        self.databaseService.saveDataToDB()
    }
    
    private func fetchAllCategoriesFromDB() {
        guard let categories = self.databaseService.genericFetchAllRecordsFromDB(entityName: Category.self) else {return}
        self.categories = categories
    }
    
    private func deleteCategoryFromDB() {}
}

// MARK: - TableView Data Source Methods

extension CategoryViewControllerTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = self.categories[indexPath.row].name
        return cell
    }
}

// MARK: - TableView Delegate Methods

extension CategoryViewControllerTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goToTodos", sender: self)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! TodoListViewController
        guard let selectedRowIndexPath = self.tableView.indexPathForSelectedRow else {return}
        destVC.category = self.categories[selectedRowIndexPath.row]
    }
}
