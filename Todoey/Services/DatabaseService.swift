//
//  DatabaseService.swift
//  Todoey
//
//  Created by Dev on 7/10/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class DatabaseService {
    static let shared = DatabaseService()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var dbContext: NSManagedObjectContext {
        return self.context
    }
    
    private init() {}
    
    public func saveDataToDB() {
        do {
            try context.save()
        }catch {
            print(error)
        }
    }

    public func fetchAllTodosFromDB() -> [Todo]? {
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        do {
            return try self.context.fetch(request)
        }catch {
            print(error)
            return nil
        }
    }
    
    public func fetchAllCategoriesFromDB() -> [Category]? {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            return try self.context.fetch(request)
        }catch {
            print(error)
            return nil
        }
    }
    
    public func updateDataInDB() {
        self.saveDataToDB()
    }
    
    public func deleteTodoFromDB(todo: Todo) {
        self.context.delete(todo)
        self.saveDataToDB()
    }
    
    public func deleteCategoryFromDB(category: Category) {
        self.context.delete(category)
        self.saveDataToDB()
    }
    
    public func fetchTodosAgainstCategoryName(categoryName: String) -> [Todo]? {
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        
        let predicate: NSPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", categoryName)
        request.predicate = predicate
        
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let result: [Todo] = try self.context.fetch(request)
            return result
        }catch {
            print(error)
            return nil
        }
    }
    
    public func fetchTodosAgainstTitle(title: String, categoryName: String) -> [Todo]?{
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        
        let titlePredicate: NSPredicate = NSPredicate(format: "title CONTAINS[cd] %@", title)
        let categoryPredicate: NSPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", categoryName)
        let compoundPredicate: NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [titlePredicate, categoryPredicate])
        request.predicate = compoundPredicate
        
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let todos: [Todo] = try self.context.fetch(request)
            return todos
        }catch {
            print(error)
        }
        return nil
    }
}
